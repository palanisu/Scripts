#!/bin/bash

echo ""
read -p "How many days report need to collect (Max 30 Days) : " input
echo ""

sudo mount | grep -i "/sftp-tank/" | grep -v grep  &> /dev/null

if [[ $? -eq 0 ]]; then 
  echo "sftp-tank mounted"
else
  echo "sftp-tank not mounted.. mounting"
  mount 10.240.73.127:/sftp-tank /sftp-tank/
  sudo mount | grep -i "/sftp-tank/" | grep -v grep  &> /dev/null
  if [[ $? -eq 0 ]]; then 
  echo "sftp-tank mounted"
  fi
fi

HSTNM=$(uname -n | cut -d. -f1)
OP="/sftp-tank/OS_Data/script_outputs/${HSTNM}_cpu_peak_usage_$(date +%d-%m-%Y-%H-%M).csv"  
echo "Server,Date,Time,Peak Value" >> $OP


COUNT=0
for file in `find /var/log/sa/* -mtime -$input -exec ls {} \; | grep -v sar`; do

DT=$(sar -f $file | | grep "Change:" | awk '{ print $2 }')
TM=$(sar -f $file | grep all | sort -nr -k4 | head -1  | awk '{ print $1$2}')
VL=$(sar -f $file | grep all | sort -nr -k4 | head -1  | awk '{ print (100 - $9)}')

if [[ $COUNT -eq 0 ]]; then
	echo "$HSTNM,\"$DT\",\"$TM\",\"$VL\"" >> $OP
else
	echo ",\"$DT\",\"$TM\",\"$VL\"" >> $OP
fi
COUNT=$((COUNT + 1))
done

/usr/bin/timeout --preserve-status 5 umount /sftp-tank

