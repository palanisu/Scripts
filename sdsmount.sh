#!/bin/bash


for i in `cat hosts`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '

sudo df -hP | grep -i /sds  &> /dev/null

if [[ $? -eq 1 ]]; then
	sudo mount -t nfs 146.89.141.138:/sds /sds -o nfsvers=3
else 
	echo "/sds Already mounted"

fi

cat << EOF 

Server : $HOSTNAME
--------------------
EOF
cat << EOF 

$(sudo df -hP /sds)

*****************************************

EOF
'
done
