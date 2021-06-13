#!/bin/bash - 
#===============================================================================
#
#          FILE: eregcheck.sh
# 
#         USAGE: ./eregcheck.sh 
# 
#===============================================================================

echo -e "Hostname,UID-GID Range in Conig,OP of protectedid.dat" > eregoutput.csv
for i in `cat host`; do RES=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 ibmadmin@$i '

HSTNM=$(uname -n | cut -d. -f1)
ERE=$(sudo grep range /opt/eregldap/uar/configure/customvar.cfg)
PRO=$(sudo cat /opt/eregldap/uar/configure/protectedid.dat)
echo "$HSTNM,\"$ERE\",\"$PRO\""
'
)
echo $RES >> eregoutput.csv
done 
