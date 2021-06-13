#!/bin/bash
USR=osadmin
SSH_OPT='-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30'
rpw_dir="/home/palani/ibm-git/outputs/pwds"
rpw_hst="/home/palani/ibm-git/hosts/hosts"
rpw_tmp="$rpw_dir/tmp_pwd"
rpw_ser="$rpw_dir/ser_pwd"
rpw_tst="$rpw_dir/ser_tst"

    cat "$rpw_ser" | awk '{ print $2 }' > $rpw_tst
    diff $rpw_tst $rpw_tmp &> /dev/null
    if [[ $? -eq 0 ]]; then

      if [[ $(find "$rpw_ser" -mtime +1 -print) ]]; then
        echo "File $rpw_ser exists and is older than 85 days"
        cnt=$(cat $rpw_hst | wc -l)
          for i in `seq 1 "${cnt}"`; do mkpasswd -l 8 -d 2 -C 3 -s 0; done >> $rpw_tmp
          paste -d" " $rpw_hst  $rpw_tmp > $rpw_ser

          
      while read server pwd; do 
      echo $server 
      echo $pwd
      #ssh $SSH_OPT $USR@$server 'echo "$pwd" | sudo passwd --stdin root'
      done < "${rpw_ser}"
    
    else
      echo "Passwords not matching"
    fi
else
  echo "Password file Latest"
fi



#fi

#for i in `cat hosts`; do ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 osadmin@$i 'echo "s3am5@8n_31karo" | sudo passwd --stdin oracle'; done 
