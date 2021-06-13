#!/bin/bash

USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
OP="/home/palani/ibm-git/outputs/package_install_status_$(date +%d-%m-%Y-%H-%M).csv"

echo "Server,Package Installed or Not,RPM Version" >> $OP

for host in `cat $HOST`; do RES=$(ssh $SSH_OPT $USR@$host '

HSTNM=$(uname -n | cut -d. -f1)

sudo rpm -qa | grep sudo &> /dev/null

if [[ $? -eq 0 ]]; then 
  PKG="Installed"
  VER=$(sudo rpm -qa --queryformat="%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" "sudo")
else
  PKG="NOT Installed"
fi

echo "$HSTNM,\"$PKG\",\"$VER\""
'
)
echo -e "$RES" >> $OP
done
