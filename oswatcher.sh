#!/bin/bash


for i in `cat host`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

cat << EOF 

Server : $HOSTNAME
--------------------
EOF

ps -ef | grep -i osw | grep -v grep &> /dev/null

if [[ $? -eq 1 ]]; then
	echo "OSwatcher not running"
else 
    echo "OSwatcher Running"

fi
'
done

