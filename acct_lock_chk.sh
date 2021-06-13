#!/bin/bash
for i in `cat host`; do RES=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

HSTNM=$(uname -n | cut -d. -f1)
C1=$(sudo passwd -S cinstall)
C2=$(sudo passwd -S iinstall)
C3=$(sudo passwd -S octagent)
C4=$(sudo chage -l cinstall | grep "Account expires" | awk -F ":" '\''{ print $2 }'\'')
C5=$(sudo chage -l iinstall | grep "Account expires" | awk -F ":" '\''{ print $2 }'\'')
C6=$(sudo chage -l octagent | grep "Account expires" | awk -F ":" '\''{ print $2 }'\'')

echo "$HSTNM,\"$C1\",\"$C2\",\"$C3\",\"$C4\",\"$C5\",\"$C6\""
'
)
echo $RES >> acct_lock.csv
done
