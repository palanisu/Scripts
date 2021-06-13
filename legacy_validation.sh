#!/bin/bash
#===============================================================================
#
#          FILE: legacy_validation.sh
# 
#         USAGE: ./legacy_validation.sh 
# 
#===============================================================================

######### Authentication *********START********** ############
# User credentials for the remote server.
USER="pkannaiy"
PASS="Ganish123@"
#----------------------------------------------------------------------
# Create a temp script to echo the SSH password, used by SSH_ASKPASS
#----------------------------------------------------------------------
SSH_ASKPASS_SCRIPT=$HOME/scripts/temp/ssh-askpass-script
cat > ${SSH_ASKPASS_SCRIPT} <<EOL
echo "${PASS}"
EOL
chmod u+x ${SSH_ASKPASS_SCRIPT}
export DISPLAY=:0
export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}
SSH_OPTIONS="-oLogLevel=error -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oConnectTimeout=10 -oNumberOfPasswordPrompts=2"
######### Authentication *********END********** ############

while read SERVER
do
setsid ssh -n ${SSH_OPTIONS} ${USER}@${SERVER} '

if [[ -f /mnt/post_data/scripts/linux_get_cem_info.ksh ]]; then 

sudo mv /var/tmp/cem_report.txt /var/tmp/cem_report_old.txt
sudo /mnt/post_data/scripts/linux_get_cem_info.ksh
sudo cat /var/tmp/cem_report.txt

else
sudo mount bi1lr001-bkup.corio.com:/export/kickstart /mnt
sudo mv /var/tmp/cem_report.txt /var/tmp/cem_report_old.txt
sudo /mnt/post_data/scripts/linux_get_cem_info.ksh
sudo cat /var/tmp/cem_report.txt
fi
'

done < hostlist
