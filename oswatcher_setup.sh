
#!/bin/bash
USR=osadmin
HOST="/home/palani/ibm-git/hosts/host"
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'

for host in `cat $HOST`; do ssh $SSH_OPT $USR@$host '

uname -n | cut -d. -f1
echo "---------------------------------"

ps -ef | grep -i osw | grep -v grep &> /dev/null

if [[ $? -eq 0 ]]; then

    echo "oswatcher running already"
else

rpm -qa | grep osw &> /dev/null

if [[ $? -eq 0 ]]; then 

echo "oswatcher installed"
if [[ -f /etc/sysconfig/oswatcher ]]; then 
    cp /etc/sysconfig/oswatcher /tmp/osw1
    diff /tmp/oswatcher /tmp/osw1 &> /dev/null
	    if [[ $? -eq 0 ]]; then
	        echo "OSwatcher configuration correct"
	    else
	        echo "OSwatcher Configuration NOT Correct.. Correcting.."
            sudo cp -p /etc/sysconfig/oswatcher /etc/sysconfig/oswatcher_bkp
               if [[ ! -d /u099/oswatcher ]]; then sudo mkdir -p /u099/oswatcher; fi
            sudo cp -p /tmp/oswatcher /etc/sysconfig/oswatcher
            sudo chmod 755 /etc/sysconfig/oswatcher
            sudo systemctl restart oswatcher
            sudo systemctl enable oswatcher
	    fi
else 
    if [[ ! -d /u099/oswatcher ]]; then sudo mkdir -p /u099/oswatcher; fi
    sudo cp -p /tmp/oswatcher /etc/sysconfig/oswatcher
    sudo chmod 755 /etc/sysconfig/oswatcher
    sudo systemctl restart oswatcher
    sudo systemctl enable oswatcher   
fi

else
    echo "oswatcher not installed.. Installing.."
        if [[ -f /tmp/oswatcher-8.3.0-1.el7.noarch.rpm ]]; then
            sudo yum install -y /tmp/oswatcher-8.3.0-1.el7.noarch.rpm
            rpm -qa | grep osw &> /dev/null
                if [[ $? -eq 0 ]]; then 
                    echo "oswatcher installed"
                    sudo cp -p /etc/sysconfig/oswatcher /etc/sysconfig/oswatcher_bkp
                    if [[ -f /tmp/oswatcher ]]; then sudo cp -p /tmp/oswatcher /etc/sysconfig/oswatcher ; fi
                    sudo chmod 755 /etc/sysconfig/oswatcher
                    if [[ ! -d /u099/oswatcher ]]; then sudo mkdir -p /u099/oswatcher; fi
                    sudo systemctl start oswatcher
                    sudo systemctl enable oswatcher
                else
                    echo "oswatcher unable to install.. Check YUM Repo"
                fi
        fi
fi

rm -f /tmp/oswatcher /tmp/oswatcher-8.3.0-1.el7.noarch.rpm

fi
'
done
