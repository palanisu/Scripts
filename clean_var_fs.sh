#!/bin/bash
## This script will clean up /var filesystem ##

VAR_SZ=$(df -hP | grep "/boot$" | awk '{ print $5 }' | sed s/%//g)
if [[ "$VAR_SZ" -gt 50 ]]; then 

#Go to the directory
cd /var/

# Check the maximum size, find and loop the direcotories

for dir in `du -sh * | awk '$1 ~ /G/ { print $2 }'`; do

  if [[ "$dir" == "cache" ]]; then
    /usr/bin/yum clean all
    /usr/bin/rm -rf /var/cache/
  fi
  
VAR_SZ1=$(df -kP | grep "/var$" | awk '{ print $4 }' )
  if [[ "$VAR_SZ1" -lt  1048576 ]]; then
    if [[ "$dir" == "log"]]; then
      cd log
      for f1 in `du -sk * | awk '{ if ($1 >= "512000") print $2 }'`; do
        if [[ -f "$f1" ]]; then
          u99=$(df -kP | grep "/u099$" )
          if [[ "$u99" -gt "5242880" ]]; then
            cp $f1 /u099/
            cd /u099
            /usr/bin/gzip -9 $f1
            mv $f1.gz /var/log/
            cd /var/log/
          else
            echo "No Space in /u099 to move and compress files.. Exiting.. "
            exit 1
          fi
        else
          echo "It's Directory.. Check manually.. Exiting.. "
          exit 2
        fi
      done
      cd /var
    fi
  else
    
      

 

  if [[ ]]
done


echo "Greater than"
else
echo "Less"
fi
