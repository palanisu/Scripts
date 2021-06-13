#!/bin/bash

# Name          : custom_script_m.sh
# Description   : If any changes or adding commands try to add in below section
#     output='HostName|Uptime|Kernel_Version|Lat_5_pkgs_ins' 
#     cmd_HostName='$(hostname)'
# USAGE         : custom_script_m.sh <File containing IP hostnames>

get_os_details()
{
ip=$1
SRVRDETAILS=`ssh -n osadmin@$ip -o BatchMode=yes -o ConnectTimeout=30 -o PasswordAuthentication=no -o StrictHostKeyChecking=no "echo SUCCESS" 2>&1`
	if [[ "${SRVRDETAILS}" =~ .*SUCCESS.* ]];then
		login=osadmin
	else
		echo -e "${ip},${hostname},\"${SRVRDETAILS}\"" > out_${DATE}_$$_${ip}.csv
		return
	fi	
res=`ssh -n -o PasswordAuthentication=no -o StrictHostKeyChecking=no ${login}@$ip "$cmds"`
echo -e "${ip},${res}" > out_${DATE}_$$_${ip}.csv
}


finalize ()
{
echo "Server Name,${header}" > ${OUTPUT_REPORT} 
cat out_${DATE}_$$_*.csv >> ${OUTPUT_REPORT}
rm -f out_${DATE}_*.csv 2>/dev/null
}

trap 'echo -e "Exiting now..\nPreparing the Report and Stopping tunnel";finalize;tput sgr0;exit' 2
bold=`tput bold`
normal=`tput sgr0`
blue='\e[34m'
green='\e[0;32m'
red='\e[31m'
DATE=$(date +%Y%m%d)
USAGE="USAGE : bash $0 [File containing Hostnames]" 
if [[ $# -lt 1 ]]; then echo -e "${bold}${red}${USAGE}${normal}"; exit 1; fi
if [[ ! -s "$1" ]]; then echo -e "${bold}${red}Given argument is not File or Empty.. \n\n$USAGE${normal}"; exit 1; fi
echo "Starting execution....."

hosts_file=$1
OUTPUT_REPORT="/home/palani/ibm-git/outputs/Kerel_Details_Report_${DATE}.csv"
##Take a backup of previous run
if [[ -f ${OUTPUT_REPORT} ]]; then mv ${OUTPUT_REPORT} $(echo ${OUTPUT_REPORT}|cut -d '.' -f1)_prev.csv;fi 

## Custom selection in below
output='Running_Kernel_Version|OS_Release'
cmd_Running_Kernel_Version='$(uptime)'
cmd_OS_Release='$(grep "\sro[\s,]" /proc/mounts)'


##### Prepare the command for retreiving details
for i in `echo $output | tr '|' ' '`;do header="${header},\"$(echo $i | tr '_' ' ')\"";eval cmd='$'"cmd_${i}";cmds="$cmds,\\\"${cmd}\\\"";done
cmds=`echo "$cmds"| sed 's/^,//g'`
cmds="echo -e \"$cmds\""
time_out=600
sleep_time=10
tot_wait_time=0
while read IP 
       	do	
                       
			get_os_details $IP  &
                        pid="$pid $!"
                        pid_ip_pair+=(["$!"]="${IP},${host_name},${CUSTOMER},${DC}")

        done < ${hosts_file}
	for proc_id in $pid
        do
                tot_wait_time=0
                while kill -0 ${proc_id} >/dev/null 2>&1; do
                        sleep ${sleep_time}
                        tot_wait_time=$(( ${tot_wait_time} + ${sleep_time} ))
                        if [[ ${time_out} -eq ${tot_wait_time} ]] && [[ $(ps -ef | grep ${proc_id} |grep -v grep) ]] ;then
                                for id in $pid
                                do
                                	kill -0 ${id} >/dev/null 2>&1
                                        if [[ $? -eq 0 ]]; then
                                        	echo -e "\nWaited too long.. killing the process-${id} -  ${pid_ip_pair["${id}"]}\n"
                                                kill -9 ${id}
                                                echo "${pid_ip_pair["${id}"]},Server took too long to get details.Aborted" >> out_${DATE}_$$_term.csv
                                        fi
                                done
				break
                        fi

                done
        done
     
echo
echo "preparing the report"
finalize
echo "Report generated : ${OUTPUT_REPORT} at $(date). Exiting..."
echo "Execution completed....."
