#!/bin/bash


for i in `cat hosts`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

cat << EOF 

Server : $HOSTNAME
--------------------

EOF

ps -ef | grep -i dsmc | grep -v grep &> /dev/null

if [[ $? -eq 1 ]]; then
	echo "dsmc process not running.. Restarting.."
	sudo /opt/tivoli/tsm/client/ba/bin/start_daemons.ksh
	sleep 2
	ps -ef | grep -i dsmc | grep -v grep &> /dev/null
	if [[ $? -eq 0 ]]; then
	echo "dsmc process running"
	else
	echo "dsmc process not running"
	fi
else 
echo "dsmc process already running"

fi
'
done
