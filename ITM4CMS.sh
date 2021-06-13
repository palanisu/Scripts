mkdir /u099/sos
cd /u099/sos
wget http://146.89.141.252/sw/ITM6_LINUX_64_063007000_SCE.tar
tar -xvf ITM6_LINUX_64_063007000_SCE.tar
cd /u099/sos/TEMA1
/opt/IBM/ITM/bin/itmcmd agent -f stop all
./cms2x_instTEMA.sh  -a lx8266 -h /opt/IBM/ITM4CMS/ -r 146.89.140.232 -l ` uname -n|cut -f1 -d "." ` -c ab3 -p none -f 146.89.140.232
/opt/IBM/ITM4CMS/bin/cinfo -r

