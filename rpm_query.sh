#!/bin/bash

for i in `cat host`; do RES=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

HSTNM=$(uname -n | cut -d. -f1)
KER=$(uname -r)
OSV=$(cat /etc/redhat-release)
echo "$HSTNM,\"$KER\",\"$OSV\""
'
)
echo $RES >> kernel_os_det.csv
done
