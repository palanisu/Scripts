#!/bin/bash

USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
OP="/home/palani/ibm-git/outputs/FS_Status_$(date +%d-%m-%Y-%H-%M).csv"

echo "Server,Filesystem,Mounted on,Filesystem State" >> $OP
for i in `cat $HOST`; 
do 
RES=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 $USR@$i '
HSTNM=$(uname -n | cut -d. -f1)
COUNT=0
sudo df -hPT | grep -vE "^Filesystem|tmpfs|cdrom|nfs|boot|xvda3" | awk '\''{ print $1","$7 }'\'' > /tmp/fs1
for filesys in `cat /tmp/fs1 | awk -F "," '\''{ print $1 }'\''`; do

FS_ST=$(sudo /usr/sbin/tune2fs -l $filesys | grep state | awk -F ":" '\''{ print $2 }'\'' | sed -e '\''s/^[ \t]*//'\'' )
FS_DV=$(cat /tmp/fs1 | grep -w $filesys | awk -F "," '\''{ print $1 }'\'')
FS_MN=$(cat /tmp/fs1 | grep -w $filesys | awk -F "," '\''{ print $2 }'\'')
if [[ $COUNT -eq 0 ]]; then
	echo "$HSTNM,\"$FS_DV\",\"$FS_MN\",\"$FS_ST\""
else
	echo ",\"$FS_DV\",\"$FS_MN\",\"$FS_ST\""
fi
COUNT=$((COUNT + 1))
done
'
)
echo -e "$RES" >> $OP
done

