#!/bin/bash
USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'

for host in `cat $HOST`; do ssh $SSH_OPT $USR@$host '
set -x
HNM=$(uname -n | cut -d. -f1)
MKD=$(whereis mkdir | awk -F " " '\''{ print $2 }'\'')
DT=$(date +%d-%m-%Y)
PTH="/var/tmp/${HNM}_${DT}"
###$($MKD $PTH)
$(sudo df -hPT > $PTH/df_hp_op)
$(sudo ip addr show > $PTH/ip_addr_op)
$(sudo netstat -nr > $PTH/netstat_nr_op)



'
done