#!/bin/bash
USR=osadmin
HOST="$1"
USAGE="USAGE : bash $0 [File containing Hostnames]" 
if [[ $# -lt 1 ]]; then echo -e "${USAGE}"; exit 1; fi
if [[ ! -s "$1" ]]; then echo -e "Given argument is not File or Empty.. \n\n$USAGE"; exit 1; fi
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
for host in `cat $HOST`; do ssh $SSH_OPT $USR@$host '
set -x
uname -n | cut -d. -f1
echo "---------------------------------"
## Group Addition
grep -i 15000 /etc/group | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow GID already present"
else
    sudo /usr/sbin/groupadd -g 15000 snow
fi
## User Addition
grep -i 15000 /etc/passwd | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow UID already present"
else
    sudo /usr/sbin/useradd -c "NL/S/*AABUNX/IBM/SNOW" -u 15000 -g 15000 -s /sbin/nologin snow
fi

## Add user in protectedid.dat file
DAT_FI="/opt/eregldap/uar/configure/protectedid.dat"
sudo grep -w "snow" $DAT_FI | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow id already added in dat file"
else
    sudo /usr/bin/cp -p $DAT_FI "${DAT_FI}"_SNOW
    sudo /usr/bin/sh -c  "echo -e \"## Snow Agent User \nsnow \" >> $DAT_FI"
fi
## snow directory
if [[ ! -d /opt/snow ]]; then 
    sudo /usr/bin/mkdir -p /opt/snow
    sudo /usr/bin/chown -R snow.snow /opt/snow/
else
    sudo /usr/bin/chown -R snow.snow /opt/snow/   
fi

## SNOW agent installation    
rpm -qa | grep snowagent-sios &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "snow is installed"
  else
    sudo /usr/bin/yum -y localinstall http://146.89.141.252/sw/ABNAMRO_snowagent-sios-6.3.1-1.x86_64.rpm
  fi
##Certification Installation
if [[ ! -d /etc/pki/ca-trust/source/anchors ]]; then 
    sudo /usr/bin/mkdir -p /etc/pki/ca-trust/source/anchors/
      cd /etc/pki/ca-trust/source/anchors/
      wget http://146.89.141.252/sw/SNOW_Certificate.cer
      sudo update-ca-trust extract
      cd /etc/pki/tls/certs/
      sudo /usr/bin/openssl x509 -in ca-bundle.crt -text -noout
else
      cd /etc/pki/ca-trust/source/anchors/
      wget http://146.89.141.252/sw/SNOW_Certificate.cer
      sudo update-ca-trust extract
      cd /etc/pki/tls/certs/
      sudo /usr/bin/openssl x509 -in ca-bundle.crt -text -noout


fi

'
done
