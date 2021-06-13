#!/bin/bash
perms=/tmp/permissons

while read -r server fil; do 
echo -e "Connecting $server"
ssh -n -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=3 osadmin@$server "sudo chmod o-w ${fil}"

done < $perms
