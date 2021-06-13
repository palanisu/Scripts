#!/bin/bash - 
#===============================================================================
#
#          FILE: ro_checks.sh
# 
#===============================================================================


for i in `cat host`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=15 osadmin@$i '

cat << EOF 

Server : $HOSTNAME
--------------------
EOF
cat << EOF 

Uptime
--------------------
$(uptime)
EOF
cat << EOF


Filesystem RO checks
----------------------
$(grep "\sro[\s,]" /proc/mounts)

*************************************
EOF
'
done
