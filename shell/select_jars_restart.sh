#!/usr/bin/env bash
#选择并重启jar
export JAVA_HOME=/usr/local/tools/jdk8
export JRE_HOME=$JAVA_HOME/jre

DISTROS=$(whiptail --title "restart jars" --checklist \
"Choose jars" 15 60 4 \
"jar1" "" OFF \
"jar2" "" OFF \
"jar3" "" OFF \
"jar4" "" OFF \
3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your favorite distros are:" $DISTROS
    for i in $DISTROS;do
        i=$(echo $i |sed s'/"//g')
        TEMP_PID=$(ps -ef|grep java|grep $i|grep -v grep |awk -F " " '{print $2}')
        echo "#### kill pid:$TEMP_PID"
        kill -9 $TEMP_PID
    done
    sleep 10
    for i in $DISTROS;do
        i=$(echo $i |sed s'/"//g')
        nohup $JAVA_HOME/bin/java -jar /jars/$i.jar --spring.profiles.active=test -Xms256m -Xmx256m >>/logs/$i.log 2>&1 &
    done

else
    echo "You chose Cancel."
fi