#!/bin/bash
log=/root/conntrack.log
TIME="`date +%m-%d` `date +%H:%M:%S`"
ps aux |grep conntrack |grep -v grep &> /dev/null 
if [ $? == "0" ] 
then
	echo  conntrack is running |sed "s/^/$TIME conntrack [log]: /g">> $log 
	free -m |grep -v Swap |sed "s/^/$TIME conntrack [log]: /g">> $log
	uptime |sed "s/^/$TIME conntrack [log]: /g">> $log
	echo "$TIME conntrack [log]: -----------------------------sh---------------------------" >> $log
else
	/usr/sbin/conntrack  -b 907374182  -E -p tcp --state ESTABLISHED -j |/root/conn-to-syslog &
	echo  conntrack is restart |sed "s/^/$TIME conntrack [log]: /g">> $log
	free -m |grep -v Swap |sed "s/^/$TIME conntrack [log]: /g">> $log
	uptime |sed "s/^/$TIME conntrack /g [log]:">> $log
	echo "$TIME conntrack [log]: -----------------------------sh---------------------------" >> $log
fi
