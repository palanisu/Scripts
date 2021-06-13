#!/bin/bash
## Group Addition
grep -i 15000 /etc/group | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow GID already present"
else
    groupadd -g 15000 snow
fi
## User Addition
grep -i 15000 /etc/passwd | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow UID already present"
else
    useradd -c "NL/S/*AABUNX/IBM/SNOW" -u 15000 -g 15000 -s /sbin/nologin snow
fi

## Add user in protectedid.dat file
DAT_FI="/opt/eregldap/uar/configure/protectedid.dat"
grep -w "snow" $DAT_FI | grep -v grep &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "snow id already added in dat file"
else
    cp -p $DAT_FI "${DAT_FI}"_SNOW
    echo -e "## Snow Agent User \nsnow " >> $DAT_FI
fi
## snow directory
if [[ ! -d /opt/snow ]]; then 
    mkdir -p /opt/snow
    chown -R snow.snow /opt/snow/
else
    chown -R snow.snow /opt/snow/   
fi

## SNOW agent installation    
rpm -qa | grep snowagent-sios &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "snow is installed"
  else
    yum localinstall -y http://146.89.141.252/sw/ABNAMRO_snowagent-sios-6.3.1-1.x86_64.rpm
  fi
##Certification Installation
if [[ ! -d /etc/pki/ca-trust/source/anchors ]]; then 
    mkdir -p /etc/pki/ca-trust/source/anchors/
      cd /etc/pki/ca-trust/source/anchors/
      wget http://146.89.141.252/sw/SNOW_Certificate.cer
      update-ca-trust extract
      cd /etc/pki/tls/certs/
      openssl x509 -in ca-bundle.crt -text -noout
else
      cd /etc/pki/ca-trust/source/anchors/
      wget http://146.89.141.252/sw/SNOW_Certificate.cer
      update-ca-trust extract
      cd /etc/pki/tls/certs/
      openssl x509 -in ca-bundle.crt -text -noout


fi
