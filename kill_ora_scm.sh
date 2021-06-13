
#!/bin/bash

ps -ef | grep "ora_scm*" | grep -v grep
if [[ $? -eq 0 ]] ;then
        
  PS=$(ps -ef | grep "ora_scm*" | grep -v grep)
  logger "Killing following process ${PS}" 
  PIDS=$(ps -ef | grep "ora_scm*" | grep -v grep | awk '{ print $2 }' )  
  kill -9 $PIDS

else

fi

