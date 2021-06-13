#!/bin/bash - 

for i in `cat host`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i '


cat << EOF 

Server : $HOSTNAME
--------------------
EOF
cat << EOF

Account lock status
----------------------
$( sudo passwd -S cinstall)
$( sudo passwd -S iinstall)
$( sudo passwd -S octagent)

Password Age cinstall 
----------------------
$(sudo chage -l cinstall )

Password Age  iinstall
-----------------------
$(sudo chage -l iinstall )
*************************************
EOF
'
done

