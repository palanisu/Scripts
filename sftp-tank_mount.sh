#!/bin/bash

hosts=$1
if [[ ! -s "$1" ]]; then echo -e "Given argument is not File or Empty.. "; exit 1; fi
for i in `cat $hosts`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

sudo df -hP | grep -i /sftp-tank  &> /dev/null

if [[ $? -eq 0 ]]; then
	echo -e "$(hostname -s)\t sftp-tank mounted"
else 
	echo -e "$(hostname -s)\t sftp-tank not mounted"

fi

'
done
