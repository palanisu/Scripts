#!/bin/bash

USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
OP="/home/palani/ibm-git/outputs/all_packages_10-03-2021-13-46.csv"

echo "Server,RPM Version" >> $OP

for host in `cat $HOST`; do RES=$(ssh $SSH_OPT $USR@$host '

HSTNM=$(uname -n | cut -d. -f1)

PKG=$(sudo rpm -qa)

echo "$HSTNM,\"$PKG\""
'
)
echo -e "$RES" >> $OP
done
