#!/bin/bash

read -p "Oracle Case No. : " csae

read -p "Path or file to upload to Oracle : " path

STE=$(/usr/bin/stat $path | sed -n 2p | awk '{ print $NF }')

if [[ "$STE" == "file" ]]; then 

  curl -s -T "$path" -o file_$csae.txt "https://transfer.sh/$csae/"
  
    elif [[ "$STE" == "directory" ]]; then 

      for files in `ls $path`; do  curl -s -T "${path}/${files}" -o file_$csae.txt "https://transfer.sh/$csae/"; done
    fi

