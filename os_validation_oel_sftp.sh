#!/bin/bash

## Script to collect server information
## Output file will be saved in /sftp-tank/OS_Data/
## 

server_info () {

echo -e " "
echo "Server Information : "
echo "============================================="

echo -e "Server Name        : $(hostname) "
echo -e "Server Type        : $(CMD_OUT=$(sudo virt-what | head -1); if [[ "$CMD_OUT" == "xen" ]]; then echo "OVM Server"; elif [[ "$CMD_OUT" == "vmware" ]]; then echo "VMWare Server"; elif [[ "$CMD_OUT" == " " ]]; then echo "Physical Server"; fi)"
echo -e "OS Type            : $(if [[ -e /etc/oracle-release ]];then echo "$(sudo cat /etc/oracle-release)";elif [[ -e /etc/redhat-release ]];then echo "$(sudo cat /etc/redhat-release)";elif [[ -e /etc/SuSE-release ]];then echo "$(sudo cat /etc/SuSE-release)";fi) "
echo -e "Server UP time     : $(uptime)"
echo -e "Kernel Release     : $(uname -r)"

}

tz_info () {
echo -e " "
echo -e "Date and Time Zone Information: "
echo -e "============================================="

echo -e "Server Date & Time :" $(date)
echo -e " "
echo -e "TimeZone Details :\n~~~~~~~~~~~~~~~~~~~~"
timedatectl status | egrep "NTP|Time zone"
echo -e " "
echo -e "TimeZone Link file :\n~~~~~~~~~~~~~~~~~~~~"
sudo ls -l /etc/localtime | awk '{ print $9 " " $10 " " $11 }'
echo -e " "
echo -e "Time Synch info :\n~~~~~~~~~~~~~~~~~"
if [[ -f /usr/bin/chronyc ]]; then /usr/bin/chronyc sources; fi
if [[ -f /usr/sbin/ntpq ]]; then /usr/sbin/ntpq -p; fi

}

cpu_mem_info() {
echo -e " "
echo -e "CPU & Memory Information : "
echo -e "============================================="
echo -e "CPU Details :\n~~~~~~~~~~~~~~~~~~~~"
sudo cat /proc/cpuinfo|grep processor|wc -l
echo -e " "
echo -e "Memory Details :\n~~~~~~~~~~~~~~~~~~~~"
free -h
echo -e " "
echo -e " Swap Device Details \n~~~~~~~~~~~~~~~~~~~~"
swapon -s
}

network_info () {
echo -e " "
echo -e "IP Addr and Network route Information:"
echo -e "============================================="
echo -e " "
echo -e "IP Address : \n~~~~~~~~~~~~~~"
sudo /sbin/ip address show | grep -w inet | egrep -v '(host|virbr)' | awk '{ print $2 }'
echo -e " "
echo -e "Routing Info :\n~~~~~~~~~~~~~~~"
sudo netstat -rn
echo -e " "
echo -e "Gateway Reachable :\n~~~~~~~~~~~~~~~~~~~~"
for IP in `sudo netstat -rn |egrep -v "Gateway|IP|table"|cut -c17-31|sort|uniq|egrep -v "0.0.0.0"`; do ping $IP -c 2 >/tmp/ping_chk; if [ `echo $?` -eq 0 ]; then  echo -e "GW IP $IP is reachable"; else  echo -e "GW IP $IP is not reachable"; fi; done
}
lvm_info () {
echo -e " "
echo -e "LVM Information : "
echo -e "============================================="
echo -e " "
echo -e "VGS :\n~~~~~~"
sudo vgs 
echo -e " "
echo -e "PVS :\n~~~~~~"
sudo pvs 
echo -e " "
echo -e "LVS :\n~~~~~~"
sudo lvs 
}

mount_info () {
echo -e " "
echo -e "Mounts : "
echo -e "============================================="
sudo df -hPT
echo -e " "
echo -e "Mount Point Comparisons : "
echo -e "============================================="
echo -e " "
echo "  Comparing fstab entries with mounted fs "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

sudo cat /etc/fstab | egrep -v "^#|^$|pts|sys|proc|swap|shm"|awk '{ print $2 }'|sort > /tmp/actual_fs
sudo df -hP | egrep -v "^#|^$|Stale|tmpfs|run|sys"|awk '{ print $6 }'|sort > /tmp/mounted_fs

for FS in `cat /tmp/actual_fs`
do
  if [[  $(egrep $FS /tmp/mounted_fs) != "" ]]; then
    printf "%-30s : %-20s \n" $FS Mounted
  else
    printf "%-30s : %-20s \n" $FS Not Mounted
  fi
done

echo -e " "
echo "  Comparing mounted fs with fstab entries"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

for FST in `cat /tmp/mounted_fs`
do
  if [[  $(egrep $FST /tmp/actual_fs) != "" ]]; then
    printf "%-30s : %-20s \n" $FST  "fstab entry present"
  else
    printf "%-30s : %-20s \n" $FST "No fstab entries"
  fi
done
sudo rm -f /tmp/actual_fs /tmp/mounted_fs /tmp/ping_chk

}

yum_info () {
echo -e " "
echo -e "Yum Repo and Config Details"
echo -e "============================================="
echo -e " "
echo -e "Check Yum repo list :\n~~~~~~~~~~~~~~~~~~~~~~~~~~"
sudo yum repolist -q
echo -e " "
echo -e "Dupe Packages :\n~~~~~~~~~~~~~~~~"
sudo /usr/bin/package-cleanup -q --dupes
echo -e " "
echo -e "RPM DB problems :\n~~~~~~~~~~~~~~~~"
sudo /usr/bin/package-cleanup -q --problems
echo -e " "
echo -e "Conflict Packages :\n~~~~~~~~~~~~~~~~~~~~"
sudo rpm -Va --nofiles --nodigest

}

agent_info () {
echo -e " "    
echo -e "Backup status Information:"
echo -e "============================================="
ps -ef|grep -i dsmc|grep -v grep

echo -e " "
echo -e "ITM Agent status Information:"
echo -e "============================================="
ps -ef | grep -i itm | grep -v grep
echo " "
sudo /opt/IBM/ITM4CMS/bin/cinfo -r

}

prepatch_report () {

cp /dev/null $PRE_REPORT

exec > $PRE_REPORT 2> /dev/null

cat << EOF

---------------------------------------------------------------------
Pre Reboot Report on $(date) for $(uname -n | cut -d. -f1)
---------------------------------------------------------------------

EOF

server_info
tz_info
cpu_mem_info
network_info
lvm_info
mount_info
yum_info
agent_info

cat << EOF
~~~~~~~~~~~~~~~~~~ Script Execution Completed ~~~~~~~~~~~~~~~~~~~~~~~
EOF
}

postpatch_report () {

cp /dev/null $POST_REPORT

exec > $POST_REPORT 2> /dev/null

cat << EOF

---------------------------------------------------------------------
Post Reboot Report on $(date) for $(uname -n | cut -d. -f1)
---------------------------------------------------------------------

EOF

server_info
tz_info
cpu_mem_info
network_info
lvm_info
mount_info
yum_info
agent_info

cat << EOF
~~~~~~~~~~~~~~~~~~ Script Execution Completed ~~~~~~~~~~~~~~~~~~~~~~~
EOF
}

config_report () {
cp /dev/null $CONFIG_REPORT
exec > $CONFIG_REPORT 2> /dev/null
cat << EOF

---------------------------------------------------------------------
Config Report on $(date) for $(uname -n | cut -d. -f1)
---------------------------------------------------------------------

EOF

echo -e "/etc/fstab Entries\n~~~~~~~~~~~~~~~~~~~~~"
sudo cat /etc/fstab
echo " "
echo -e "/etc/resolv.conf Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo cat /etc/resolv.conf
echo " "
echo -e "lsblk -f Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo lsblk -f
echo " "
echo -e "blkid Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo blkid
echo " "
echo -e "PV Display Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo pvdisplay
echo " "
echo -e "VG Display Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo vgdisplay
echo " "
echo -e "LV Display Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo lvdisplay
echo " "
echo -e "Network Devices IP Details\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
for i in `ls /etc/sysconfig/network-scripts/ifcfg-eth*`; do echo $i | awk -F "/" '{ print "Network Device", $5, "IP Details\n" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" }'; sudo cat $i; echo " " ; done
echo " "
echo -e "Network Devices Route Details\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
for i in `ls /etc/sysconfig/network-scripts/route-eth*`; do echo $i | awk -F "/" '{ print "Network Device", $5, "Route Details\n" "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" }'; sudo cat $i; echo " " ; done
echo " "
echo -e "rpm -qa Results\n~~~~~~~~~~~~~~~~~~~~~"
sudo rpm -qa
echo " "

cat << EOF

~~~~~~~~~~~~~~~~~~ Script Execution Completed ~~~~~~~~~~~~~~~~~~~~~~~
EOF
}


read -p "Provide Ref. Info: " chg
while [[ -z $chg ]]; do 
  read -p "Provide Ref. Info: " chg 
    if [[ -z $chg ]]; then 
      continue
    fi
done

DR1=$(dirname $(readlink -f "$0"))
DR2=$(dirname $(readlink -f "$DR1"))
OP_DIR="${DR2}/script_outputs"
HSTNM=$(uname -n | cut -d. -f1)
PRE_REPORT="$OP_DIR/${chg}-${HSTNM}-pre_reboot_report.txt"
POST_REPORT="$OP_DIR/${chg}-${HSTNM}-post_reboot_report.txt"
CONFIG_REPORT="$OP_DIR/${chg}-${HSTNM}-config_report.txt"

echo ""
echo "1 For Pre Reboot report"
echo "2 For Post Reboot report"
echo ""
read -p "Please enter the value 1 (or) 2: " val

case $val in 

1)
prepatch_report
config_report
;;


2)
postpatch_report
;;
*)
echo "Please give correct values" ;;
esac
