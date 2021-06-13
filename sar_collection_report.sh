#!/bin/bash

## Sar Collection Report

echo ""
read -p "How many days report need to collect (Max 30 Days) : " input
echo ""
HSTNM=$(uname -n | cut -d. -f1)
DR1=$(dirname $(readlink -f "$0"))
DR2=$(dirname $(readlink -f "$DR1"))
OP_DIR="${DR2}/script_outputs"
SAR_REPORT="$OP_DIR/${HSTNM}-sar_report.txt"


for file in `find /var/log/sa/* -mtime -$input -exec ls {} \; | grep -v sar`; do

LC_ALL=C sar -A -f $file >> $SAR_REPORT
done

