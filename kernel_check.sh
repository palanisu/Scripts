#!/bin/bash
USR=osadmin
OP="/home/palani/ibm-git/outputs/kernel_det_$(date +%d-%m-%Y-%H-%M).csv"
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'

for host in `cat $HOST`; do RES=$(ssh $SSH_OPT $USR@$host '

HSTNM=$(uname -n | cut -d. -f1)
KER=$(uname -r)
KER_LAT=$(rpm -qa --last | grep -w kernel-uek | grep -v firmware | sort -nr | head -1 | awk -F " " '\''{ print $1 }'\'')
KER_LAT_PAT=$(rpm -qa --last | grep -w kernel-uek | grep -v firmware | sort -nr | head -1 | awk -F " " '\''{ print $3$4$5 }'\'')
echo "$HSTNM,\"$KER\",\"$KER_LAT\",\"$KER_LAT_PAT\""
'
)
echo $RES >> "${OP}"
done
