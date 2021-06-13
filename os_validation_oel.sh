#################################################################################################
# Name          : os_validation.sh                                                            	#
# Description   : This script allows users to collect server information in short time.       	#
# Author        : Ravikanth Adapa (raviadapa@in.ibm.com) 					#
# Modified      : Adyantha T S (adyantts@in.ibm.com)						#
# Modified	: Palani K (palani.k@ibm.com)	                                                #
# Version       : 2.2									        #
# Modified the script as per Oracle Linux 7 (Palani K)                                          #
#################################################################################################

USAGE="Usage os_validation.sh [file with Server IPs]"
if [ $# -lt 1 ] || [ ! -f $1 ]
then 
  echo "$USAGE"
else
echo "Starting execution....."
for host in `cat $1`; do
SRVRDETAILS=`ssh -n osadmin@$host -o ConnectTimeout=30 -o PasswordAuthentication=no -o StrictHostKeyChecking=no "echo SUCCESS" 2>&1`
if [[ "${SRVRDETAILS}" =~ .*SUCCESS.* ]];then
	echo ""
	echo -e " ***************** Collecting details for $host ***************** "
ssh -n osadmin@$host -o ConnectTimeout=30 -o PasswordAuthentication=no -o StrictHostKeyChecking=no '
cat << EOF
=============================================
Server Information : 
=============================================

Server Name        : $HOSTNAME
Server Type        : $(CMD_OUT=$(sudo virt-what | head -1); if [[ "$CMD_OUT" == "xen" ]]; then echo "OVM Server"; elif [[ "$CMD_OUT" == "vmware" ]]; then echo "VMWare Server"; elif [[ "$CMD_OUT" == " " ]]; then echo "Physical Server"; fi)
OS Type            : $(if [[ -e /etc/oracle-release ]];then echo "$(sudo cat /etc/oracle-release)";elif [[ -e /etc/redhat-release ]];then echo "$(sudo cat /etc/redhat-release)";elif [[ -e /etc/SuSE-release ]];then echo "$(sudo cat /etc/SuSE-release)";fi) 
Server UP time     : $(uptime)
Kernel Release     : $(uname -r)

EOF

cat << EOF
=============================================
Date and Time Zone Information:
=============================================

Server Date & Time : $(date)
~~~~~~~~~~~~~~~~~~~~

TimeZone Details :
~~~~~~~~~~~~~~~~~~~~
$(timedatectl status | egrep "NTP|Time zone")

TimeZone Link file :
~~~~~~~~~~~~~~~~~~~~
$(ls -l /etc/localtime | awk '\''{ print $9 " " $10 " " $11 }'\'')

Time Synch info :
~~~~~~~~~~~~~~~~~
$(if [[ -f /usr/bin/chronyc ]]; then /usr/bin/chronyc sources; fi)
$(if [[ -f /usr/sbin/ntpq ]]; then /usr/sbin/ntpq -p; fi)

EOF

cat << EOF
=============================================
Check CPU Information : 
=============================================

$(echo -n "Number of Processors: ";  sudo cat /proc/cpuinfo|grep processor|wc -l)

EOF

cat << EOF 
=============================================
Memory & Swap Information :
=============================================

$(free -h)

EOF

cat << EOF 
=============================================
IP Addr and Network route Information:
=============================================

IP Address :
~~~~~~~~~~~~~~
$(sudo /sbin/ip address show | grep -w inet | egrep -v '\''(host|virbr)'\'' | awk '\''{ print $2 }'\'')

Routing Info :
~~~~~~~~~~~~~~~
$(sudo netstat -rn)

Gateway Reachable :
~~~~~~~~~~~~~~~~~~~~
$(for IP in `sudo netstat -rn |egrep -v "Gateway|IP|table"|cut -c17-31|sort|uniq|egrep -v "0.0.0.0"`; do ping $IP -c 2 >/tmp/ping_chk; if [ `echo $?` -eq 0 ]; then  echo -e "GW IP $IP is reachable"; else  echo -e "GW IP $IP is not reachable"; fi; done)

EOF

cat << EOF
=============================================
LVM Information : 
=============================================
VGS :
~~~~~~
$(vg_path=$(whereis vgs | cut -d " " -f2);sudo $vg_path)

PVS :
~~~~~~
$(pv_path=$(whereis pvs | cut -d " " -f2);sudo $pv_path)

LVS :
~~~~~~
$(lv_path=$(whereis lvs | cut -d " " -f2);sudo $lv_path)
EOF

cat << EOF

$(sudo cat /etc/fstab | egrep -v "^#|^$|pts|sys|proc|swap|shm"|awk '\''{ print $2; }'\''|sort > /tmp/actual_fs)
$(sudo df -hP | egrep -v "^#|^$|Stale|tmpfs|run|sys"|awk '\''{ print $6; }'\''|sort > /tmp/mounted_fs) 

=============================================
Mounts : 
=============================================
$(df -hP)

=============================================
Mount Point Comparisons : 
=============================================

$(echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
$(echo "  Comparing fstab entries with mounted fs ")
$(echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

$(for FS in `cat /tmp/actual_fs`
do
        if [[  $(egrep $FS /tmp/mounted_fs) != "" ]]; then

                echo -e "$FS\t\t => mounted as per fstab entry."
        else
                echo -e "$FS\t\t => not mounted."
        fi
done)

$(echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
$(echo "  Comparing mounted fs and fstab entries")
$(echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

$(for FST in `cat /tmp/mounted_fs`
do
        if [[  $(egrep $FST /tmp/actual_fs) != "" ]]; then

                echo -e "$FST\t\t => fstab entry present"
        else
                echo -e "$FST\t\t =>  No fstab entry for this mounted filesystem"
        fi
done)
$(sudo rm -f /tmp/actual_fs /tmp/mounted_fs /tmp/ping_chk)
EOF


cat <<EOF
=============================================
Yum Repo and Config Details
=============================================

Check Yum repo and any Latest Packages installed : 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
$( sudo yum repolist ; if [ -f /var/log/yum.log ]; then sudo cat /var/log/yum.log|egrep `date +%b`|egrep `date +%d`;fi)

Dupe Packages :
~~~~~~~~~~~~~~~~
$(sudo /usr/bin/package-cleanup --dupes)

Conflict Packages :
~~~~~~~~~~~~~~~~~~~~
$(sudo rpm -Va --nofiles --nodigest)

RPM DB problems :
~~~~~~~~~~~~~~~~-
$(sudo /usr/bin/package-cleanup --problems)
EOF

cat << EOF       
=============================================
DSMCAD status Information:
=============================================
$(ps -ef|grep -i dsmc|grep -v grep)

EOF

cat << EOF       
=============================================
ITM Agent status Information:
=============================================
$(sudo /opt/IBM/ITM4CMS/bin/cinfo -r)

EOF

'
echo -e " ***************************** Completed **************************** "
else
	echo "Failed to connect the server $host"
fi

echo ""
done
echo "Completed execution....."
fi


