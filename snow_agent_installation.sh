#!/bin/bash
USR=osadmin
HOST="/home/vamsi/scripts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
for host in `cat $HOST`; do ssh $SSH_OPT $USR@$host '
uname -n | cut -d. -f1
echo "---------------------------------"
grep -i 15000 /etc/group | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow GID already created"
    exit 1
else
    sudo groupadd -g 15000 snow
fi

grep -i snow /etc/passwd | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow id already created"
else
    sudo useradd -c "NL/S/*AABUNX/IBM/SNOW" -u 15000 -g 15000 -s /sbin/nologin snow
fi

DAT_FI="/opt/eregldap/uar/configure/protectedid.dat"
sudo grep -w "snow" $DAT_FI | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow id already added in dat file"
else
    sudo cp -p $DAT_FI "${DAT_FI}"_SNOW
    sudo sh -c  "echo -e \"## Snow Agent User \nsnow \" >> $DAT_FI"
fi

rpm -qa | grep snowagent-sios &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "snow is installed"
  else
    sudo rpm -i http://10.240.58.129/ABNAMRO_snowagent-sios-6.2.2-1.x86_64.rpm
  fi
        
if [[ ! -d /opt/snow ]]; then 
    sudo mkdir -p /opt/snow
    sudo chown -R snow.snow /opt/snow/
else
    sudo chown -R snow.snow /opt/snow/   
fi

sudo grep -w "snow" /etc/sudoers | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow id already added in sudoers file"
else
    sudo cp -p /etc/sudoers /etc/sudoers_SNOW
    sudo sh -c  "echo -e \"## Snow Agent User \nCmnd_Alias SNOWAGENT = /usr/bin/dmidecode, /usr/bin/ls\nsnow ALL=(ALL) NOPASSWD: SNOWAGENT \" >> /etc/sudoers"
fi

'
done
