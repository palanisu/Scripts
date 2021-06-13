#!/bin/bash
echo " "
read -p "Oracle Case No. : " csae
echo " "
read -p "Path or file to upload to Oracle : " path

STE=$(/usr/bin/stat $path | sed -n 2p | awk '{ print $NF }'

if [[ "$STE" == "file" ]]; then 

  curl -s --proxy 146.89.148.133:443 -T "$path" -o file_$csae.txt -u oraclet@us.ibm.com:metalink1 "https://transport.oracle.com/upload/issue/$csae/"
  
    elif [[ "$STE" == "directory" ]]; then 

      for files in `ls $path`; do  curl -s --proxy 146.89.148.133:443 -T "${path}/${files}" -o file_$csae.txt -u oraclet@us.ibm.com:metalink1 "https://transport.oracle.com/upload/issue/$csae/"; done
  
fi

