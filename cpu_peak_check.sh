#!/bin/bash

USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
OP="/home/palani/ibm-git/outputs/cpu_usage_$(date +%d-%m-%Y-%H-%M).csv"
echo ""
read -p "How many days report need to collect (Max 30 Days) : " input
echo ""
for host in `cat $HOST`; do ssh $SSH_OPT $USR@$host "echo $input > /tmp/input"; done

echo "Server,Date,Time,Peak Value" >> $OP

for host in `cat $HOST`; do RES=$(ssh $SSH_OPT $USR@$host '
HSTNM=$(uname -n | cut -d. -f1)
input=`cat /tmp/input`
COUNT=0
for file in `find /var/log/sa/* -mtime -$input -exec ls {} \; | grep -v sar`; do

DT=$(sar -f $file | head -n 1 | awk '\''{print $4}'\'')
TM=$(sar -f $file | grep all | sort -nr -k4 | head -1  | awk '\''{ print $1$2}'\'')
VL=$(sar -f $file | grep all | sort -nr -k4 | head -1  | awk '\''{ print (100 - $9)}'\'')

if [[ $COUNT -eq 0 ]]; then
	echo "$HSTNM,\"$DT\",\"$TM\",\"$VL\""
else
	echo ",\"$DT\",\"$TM\",\"$VL\""
fi
COUNT=$((COUNT + 1))
done
'
)
echo -e "$RES" >> $OP
done
