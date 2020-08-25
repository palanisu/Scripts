#!/bin/bash
#################################################################################################
# Name          : os_validation.sh                                                            	#
# Description   : This script allows users to collect server information in short time.       	#
# Author        : Ravikanth Adapa (raviadapa@in.ibm.com) 					#
# Modified      : Adyantha T S (adyantts@in.ibm.com)                                    	#
# Version       : 2.11										#
# Added checks to verify source( Server with IPs) files exists ( Jul 31 2015)                 	#
# Added NTP check   ( Jul 31 2015) 								#
# Added GPFS checks ( Nov 04 2015)                                                            	#
# Added Network checks ( Nov 18 2015)                                                         	#
# Added Memory check (Dec 2 2015)                                                             	#
# Added GW IP reachable and CPU check (Dec 31 2015)                                     	#
# Added check to see latest packages are updated on system(Jan 22 2016)                  	#
# Added more checks for GPFS & modified checking number processor used ( Jul 13 2016)		#
# Added check for vmware version( Sep 13 2016 )     						#
# Added Yum repo check (Sep 27 2016)                                                            #
# Check Backup status (Oct 3 2016 )                                                             #
# Added Server Type(VMWare/Physical/OVM) and OS Type(Redhat/SuSE/Oracle) (June 30 2017)	        #
# Added Kernel release	(June 30 2017)								# 
# Added dupe packages and RPM DB Problems (June 30 2017)					#
# Added conflict packages (July 05 2017)							#
# Added LV/PV/VG status checks (July 19 2017)							#
#################################################################################################

green_bk='\e[30;48;5;82m'
red='\e[31m'
bold=`tput bold`

USAGE="Usage os_validation.sh [file with Server IPs]"
if [ $# -lt 1 ] || [ ! -f $1 ]
then 
  echo "$USAGE"
else
echo "Starting execution....."
for IP in `cat $1`
do

	SRVRDETAILS=`ssh -n oralls@$IP -o ConnectTimeout=60 -o PasswordAuthentication=no -o StrictHostKeyChecking=no "uname -sn"` >/dev/null 2>&1

if [ $? == 0 ]; then
	
	echo ""
	echo "Connecting to $IP"

ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no oralls@$IP '

cat << EOF
-------------------------------------------------------------------------------------------------------------------
Server Info :
----------------
Server : $HOSTNAME

Server Type : $(if [[ $(sudo /sbin/fdisk -l | grep -i "Disk /dev/sda") ]];then echo "VMWare/Physical";elif [[ $(sudo /sbin/fdisk -l | grep -i "Disk /dev/xvd") ]];then echo "OVM server";fi) 

OS Type : $(if [[ -e /etc/oracle-release ]];then echo "$(sudo cat /etc/oracle-release)";elif [[ -e /etc/redhat-release ]];then echo "$(sudo cat /etc/redhat-release)";elif [[ -e /etc/SuSE-release ]];then echo "$(sudo cat /etc/SuSE-release)";fi) 

Server UP time:
---------------
$(uptime)

Kernel Release :
----------------
$(uname -r)
===============================
EOF

cat << EOF 

$(if [ -f /usr/lpp/mmfs/bin/mmgetstate ] ; then echo ================================================= ; echo "GPFS Information :" ; sudo /usr/lpp/mmfs/bin/mmgetstate; sudo /usr/lpp/mmfs/bin/mmlsnsd ; sudo /usr/lpp/mmfs/bin/mmlsconfig; sudo /usr/lpp/mmfs/bin/mmlscluster; sudo /usr/lpp/mmfs/bin/mmgetstate; sudo /usr/lpp/mmfs/bin/mmlsfs /dev/sapmntdata; sudo /usr/lpp/mmfs/bin/mmauth show all;sudo /usr/lpp/mmfs/bin/mmlscallback; fi )
EOF

cat << EOF
===============================
Date and Time Zone Information:
-------------------------------
$(date)
$(cat /etc/sysconfig/clock|egrep -v "^#|^$")
$(if [ -f /etc/init.d/ntp ] ; then sudo /etc/init.d/ntp status; fi)
$(if [ -f /etc/init.d/ntpd ] ; then sudo /etc/init.d/ntpd status; fi)
$(/usr/sbin/ntpq -p)

EOF

cat << EOF       


==========================
DSMCAD status Information:
--------------------------
$(ps -ef|grep -i dsmc|grep -v grep)
EOF

cat << EOF


============================
VM Tools Status Information:
----------------------------

$(ps -ef | egrep -i "vmtoolsd|vmware-guestd" | grep -v grep; if [ -f /usr/bin/vmware-toolbox-cmd ] ; then sudo /usr/bin/vmware-toolbox-cmd -v; fi)
EOF

cat << EOF       

=============================
ITM Agent status Information:
-----------------------------
$(sudo /opt/IBM/ITM/bin/cinfo -r)
EOF

cat << EOF
=================================
Check CPU Information : 
----------------------------------
$(echo -n "Number of Processors:";  sudo cat /proc/cpuinfo|grep processor|wc -l)
EOF


cat << EOF 
=============================
Network route & Interface Information:
-----------------------------
$(sudo netstat -rn)
$(sudo /sbin/ifconfig -a|egrep Ethernet -A 1)
$(for IP in `sudo netstat -rn |egrep -v "Gateway|IP|table"|cut -c17-31|sort|uniq|egrep -v "0.0.0.0"`; do ping $IP -c 2 >/tmp/ping_chk; if [ `echo $?` -eq 0 ]; then  echo -e "GW IP $IP is reachable"; else  echo -e "GW IP $IP is not reachable"; fi; done)
EOF
cat << EOF 
=============================
Memory & Swap Information :
-----------------------------
$(free)
EOF

cat <<EOF
======================================
Check Yum repo and any Latest Packages installed : 
---------------------------------------
$( sudo yum repolist ; if [ -f /var/log/yum.log ]; then sudo cat /var/log/yum.log|egrep `date +%b`|egrep `date +%d`;fi)
======================================
Dupe Packages :
--------------
$(sudo /usr/bin/package-cleanup --dupes)
======================================
Conflict Packages :
------------------
$(sudo rpm -Va --nofiles --nodigest)
======================================
RPM DB problems :
-----------------
$(sudo /usr/bin/package-cleanup --problems)
EOF

cat <<EOF
======================================
Check Backup Status : 
---------------------------------------
$( sudo dsmc q fi )
======================================
Check LV/VG/PV Status : 
---------------------------------------
VGS:
$(vg_path=$(whereis vgs | cut -d " " -f2);sudo $vg_path)
------------------
PVS:
$(pv_path=$(whereis pvs | cut -d " " -f2);sudo $pv_path)
-----------------
LVS:
$(lv_path=$(whereis lvs | cut -d " " -f2);sudo $lv_path)
EOF



'

cat << EOF       


========================
File System Information:
------------------------
EOF

ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no oralls@$IP "cat /etc/fstab" > /tmp/actual_fs1
ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no oralls@$IP "sudo df -hP" > /tmp/mounted_fs1
cat /tmp/mounted_fs1
cat /tmp/actual_fs1|egrep -v "^#|^$|pts|sys|proc|swap|shm"|awk '{ print $2; }'|sort > /tmp/actual_fs
cat /tmp/mounted_fs1|egrep -v "^#|^$|Stale"|awk 'NR>1 { print $6; }'|sort > /tmp/mounted_fs

for FILESYSTEM in `cat /tmp/actual_fs`
do
        if [[  $(egrep $FILESYSTEM /tmp/mounted_fs) != "" ]]; then

                echo "$FILESYSTEM	mounted as per fstab entry."
        else
                echo "$FILESYSTEM	not mounted."
        fi
done

else

        echo "Failed to connect the server $IP"

fi

rm -rf /tmp/actual_fs1 /tmp/mounted_fs1
echo ""
done
echo "Completed execution....."
fi
