#!/bin/bash

for i in `cat host`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '
USER=slssabiglou
ps -ef | grep -i $USER | grep -v grep &> /dev/null

if [[ $? -eq 1 ]]; then
  echo "No process running with user $USER"
  /usr/bin/id $USER &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "User $USER present in server.. Deleting user.."
    sudo userdel -r -f $USER
  else
    echo "User $USER not present in server.."
  fi
else   
  echo "Some process for user $USER running.. Kindly check Manually"
fi
'
done
