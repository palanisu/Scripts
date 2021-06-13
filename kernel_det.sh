#!/bin/bash

for i in `cat host`; do RES=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

HSTNM=$(uname -n | cut -d. -f1)
KER=$(uname -r)
OSV=$(sudo cat /etc/os-release | grep "PRETTY_NAME=")
echo "$HSTNM,\"$KER\",\"$OSV\""
'
)
echo $RES >> kernel_os_det.csv
done
