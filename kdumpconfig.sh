#!/bin/sh
echo Kdump Helper is starting to configure kdump service

#kexec-tools checking
if ! rpm -q kexec-tools > /dev/null
then 
    echo "kexec-tools not found, please run command yum install kexec-tools to install it"
    exit 1
fi
mem_total=`free -g |awk 'NR==2 {print $2 }'`
echo Your total memory is $mem_total G

#Check if the system is legacy-boot or UEFI and then add crash kernel
#https://access.redhat.com/site/solutions/916043
cat /sys/firmware/efi/systab >& /dev/null
if [ $? == 0 ]; then
    echo "Detected UEFI-boot"
    grub_conf=/boot/efi/EFI/redhat/grub.cfg
    grub_conf_kdumphelper=/boot/efi/EFI/redhat/grub.cfg.kdumphelper.$(date +%y-%m-%d-%H_%M_%S)
else
    echo "Detected Legacy-boot"
    grub_conf=/boot/grub2/grub.cfg
    grub_conf_kdumphelper=/boot/grub2/grub.cfg.kdumphelper.$(date +%y-%m-%d-%H:%M:%S)
fi
echo backup $grub_conf to $grub_conf_kdumphelper 
cp $grub_conf $grub_conf_kdumphelper 
compute_rhel7_crash_kernel ()
{
    mem_size=$1
    if [ $mem_size -le 2 ]
    then
        reserved_memory="128M"
    else
        reserved_memory="auto"
    fi
    echo "$reserved_memory"
}
crashkernel_para=`compute_rhel7_crash_kernel $mem_total `
echo crashkernel=$crashkernel_para is set in $grub_conf
sed -i  '/^\tlinux/ s/crashkernel=\(auto\|[[:digit:]]*[mM]@[[:digit:]]*[mM]\|[[:digit:]]*[mM]\)//g' $grub_conf
sed -i ' /^\tlinux/  s/$/ crashkernel='$crashkernel_para'/g' $grub_conf

#backup kdump.conf
kdump_conf=/etc/kdump.conf
kdump_conf_kdumphelper=/etc/kdump.conf.kdumphelper.$(date +%y-%m-%d-%H:%M:%S)
echo backup $kdump_conf to $kdump_conf_kdumphelper
cp $kdump_conf $kdump_conf_kdumphelper
nfs_export=10.10.10.10:/export/tmp
echo nfs $nfs_export > $kdump_conf
dump_level=1
echo core_collector makedumpfile -c --message-level 1 -d $dump_level >> $kdump_conf
echo 'default reboot' >>  $kdump_conf

#Check if the NFS export direcotry is mounted.
mount | awk '{print $1}'| grep $nfs_export >> /dev/null
if [ $? -ne 0 ]; then
    echo "==== Your dump NFS export directory $nfs_export is not mounted. Mount it and try again. ===="
    exit  0
else
    cat /etc/fstab | awk '{print $1}' | grep ^${nfs_export} >> /dev/null
    if [ $? -ne 0 ]; then
        echo "==== You need to add an entry in the /etc/fstab to make sure the dump directory is auto-mounted after system reboot. ===="
    fi
fi

#enable kdump service
echo enable kdump service...
systemctl enable kdump.service
systemctl -a|grep kdump
systemctl restart kdump.service

#kernel parameter change
echo Starting to Configure extra diagnostic options
sysctl_conf=/etc/sysctl.conf
sysctl_conf_kdumphelper=/etc/sysctl.conf.kdumphelper.$(date +%y-%m-%d-%H:%M:%S)
echo backup $sysctl_conf to $sysctl_conf_kdumphelper
cp $sysctl_conf $sysctl_conf_kdumphelper

#server hang
sed -i '/^kernel.sysrq/ s/kernel/#kernel/g ' $sysctl_conf 
echo >> $sysctl_conf
echo '#Panic on sysrq and nmi button, magic button alt+printscreen+c or nmi button could be pressed to collect a vmcore' >> $sysctl_conf
echo '#Added by kdumphelper, more information about it can be found in solution below' >> $sysctl_conf
echo '#https://access.redhat.com/site/solutions/2023' >> $sysctl_conf
echo 'kernel.sysrq=1' >> $sysctl_conf
echo 'kernel.sysrq=1 set in /etc/sysctl.conf'
echo '#https://access.redhat.com/site/solutions/125103' >> $sysctl_conf
echo 'kernel.unknown_nmi_panic=1' >> $sysctl_conf
echo 'kernel.unknown_nmi_panic=1  set in /etc/sysctl.conf'
sysctl -p &> /dev/null

#softlockup
sed -i '/^kernel.softlockup_panic/ s/kernel/#kernel/g ' $sysctl_conf 
echo >> $sysctl_conf
echo '#Panic on soft lockups.' >> $sysctl_conf
echo '#Added by kdumphelper, more information about it can be found in solution below' >> $sysctl_conf
echo '#https://access.redhat.com/site/solutions/19541' >> $sysctl_conf
echo 'kernel.softlockup_panic=1' >> $sysctl_conf
echo 'kernel.softlockup_panic=1 set in /etc/sysctl.conf'
sysctl -p &> /dev/null

#oom
sed -i '/^kernel.panic_on_oom/ s/kernel/#kernel/g ' $sysctl_conf 
echo >> $sysctl_conf
echo '#Panic on out of memory.' >> $sysctl_conf
echo '#Added by kdumphelper, more information about it can be found in solution below' >> $sysctl_conf
echo '#https://access.redhat.com/site/solutions/20985' >> $sysctl_conf
echo 'vm.panic_on_oom=1' >> $sysctl_conf
echo 'vm.panic_on_oom=1 set in /etc/sysctl.conf'
sysctl -p &> /dev/null

