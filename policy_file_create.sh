#!/bin/bash
USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'

for host in `cat $HOST`; do ssh $SSH_OPT $USR@$host '
HSTNM=$(uname -n | cut -d. -f1)
host="BigFixPolicy_"${HSTNM}
[ -d /tmp/${host} ] && rm -rf /tmp/${host};
  mkdir /tmp/${host}

  for i in $(sudo ls /var/opt/BESClient/__GTS/__IEMHC/); do 
    FILE=$(sudo find /var/opt/BESClient/__GTS/__IEMHC/$i -type f -name policy_result.xml)
#    sudo ls -l $FILE  &> /dev/null
#    if [[ $? -eq 0 ]]; then
     if [[ ! -z $FILE ]]; then
      DT=$(sudo date -r $FILE "+%Y-%m-%d_%H_%M")
      sudo cp $FILE /tmp/${host}/${i}_${HSTNM}_${DT}_policy_result.xml
    fi
  done
    sudo chown -R osadmin:ossupp /tmp/${host};
'
done

