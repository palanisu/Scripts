#!/bin/bash
perms=/tmp/permissons
OP="/home/palani/ibm-git/outputs/permissions_output_$(date +%d-%m-%Y-%H-%M).csv"

while read -r server fil; do 

OPT=$(ssh -n -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=3 osadmin@$server "sudo ls -l ${fil} | awk '{ print \$1}'")
echo -e "$server,$fil,$OPT" >> $OP
done < $perms
