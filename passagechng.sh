#!/bin/bash - 

USER=burlls

for i in `cat host`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

cat << EOF 

Server : $HOSTNAME
--------------------
EOF

$(PE=sudo chage -l $USER | grep "Password expires" | awk -F ":" '\''{ print $2 }'\''; if [ $PE == never ]; then echo -e "$USER Already Non Expiry"; else sudo chage -M 99999 $USER; fi)

cat << EOF
Password Age $USER
-----------------------------
$(sudo chage -l $USER | grep "Password expires")
*************************************
EOF
'
done
