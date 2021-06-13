#!/bin/bash

DATE=$(date +%Y%m%d)
DATE_S=$(date +%Y%m%d%H%M%S)

OUTPUT_REPORT="SERVER_ACCESS_REPORT_${DATE}.csv"
OLD_OUTPUT_REPORT="SERVER_ACCESS_REPORT_${DATE_S}.csv"
if [[ -f ${OUTPUT_REPORT} ]]; then mv ${OUTPUT_REPORT} ${OLD_OUTPUT_REPORT} ;fi

echo "Host Name,Server Access" > ${OUTPUT_REPORT} 

while read host ; do

SRVRDETAILS=`ssh -n osadmin@$host -o BatchMode=yes -o ConnectTimeout=30 -o PasswordAuthentication=no -o StrictHostKeyChecking=no "echo SUCCESS" 2>&1`
if [[ "${SRVRDETAILS}" =~ .*SUCCESS.* ]];then
        login=osadmin
        osa=Yes
else
        osa=No
fi


echo -e "${host},${osa}" >> $OUTPUT_REPORT

done < hosts
