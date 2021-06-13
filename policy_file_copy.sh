#!/bin/bash
USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SCP_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
OP="/home/palani/ibm-git/outputs/policy_results"

[ ! -d ${OP} ] && mkdir $OP

for host in `cat $HOST`; do scp -q ${SCP_OPT} $USR@$host:/tmp/BigFixPolicy_"${host}"/*.xml $OP; done
