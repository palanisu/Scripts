#!/bin/bash

USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
OP="/home/palani/ibm-git/outputs/sar_file_status_$(date +%d-%m-%Y-%H-%M).csv"

echo "Server,Package Installed or Not,Latest SAR File Present or Not and Age of file" >> $OP

for host in `cat $HOST`; do RES=$(ssh $SSH_OPT $USR@$host '

HSTNM=$(uname -n | cut -d. -f1)

rpm -qa | grep sysstat &> /dev/null

if [[ $? -eq 0 ]]; then 
  SAR_PKG="Installed"
  
  FIL=$(ls -lrt /var/log/sa/* |grep -v sar | tail -1 | awk -F " " '\''{print $9}'\'')
			if [[ ! -z "$FIL" ]]; then
        FIL1=$(stat -c "%y"  $FIL | awk -F. '\''{ print $1 }'\'')
			    if [ "$(( $(date +"%s") - $(stat -c "%Y" $FIL) ))" -lt "86400" ]; then
			      SAR_FILE="Latest ($FIL1)"
			    else
			      SAR_FILE="Older ($FIL1)"
			    fi
			  else
			    SAR_FILE="SAR file NOT Present"
			fi
else
  SAR_PKG="NOT Installed"
fi

echo "$HSTNM,\"$SAR_PKG\",\"$SAR_FILE\""
'
)
echo -e "$RES" >> $OP
done

