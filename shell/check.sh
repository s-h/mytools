#!/usr/bin/env bash
set -f
TXT=$1
trace () {
	dos2unix $TXT &>/dev/null
	sed -i "/^\s*$/d" $TXT
	echo > /tmp/tracert.txt.log
	for ip in $i ;do
        traceroute -n -m 4 $ip > /tmp/tracert.txt
	cat /tmp/tracert.txt >> /tmp/tracert.txt.log
        txt=`grep " 3  " /tmp/tracert.txt |sed -e 's/ 3  //g' -e 's/\s.*//g'`
        if [ $txt = 10.115.xxx.xxx ];then
                echo "$ip ----> BGP"
	elif [ $txt = 14.197.xxx.xxx ];then
                echo "$ip ----> 大网"
        elif [ $txt = 14.197.xxx.xxx ];then
                echo "$ip ----> 大网"
        elif [ $txt = 14.197.xxx.xxx ];then
                echo "$ip ----> 大网"
        elif [ $txt = 10.40.xxx.xxx ];then
                echo "$ip ----> bgp_nat"
        else
                echo "$ip ----> $txt"
        fi

done
}
main () {
while read i;do
	if [[ "$i" =~ "##" ]];then
		echo $i
	elif [[ "$i" =~ "#" ]];then
		echo >/dev/null
	else
		trace $i
	fi
done < $TXT
}
myhelp() {
	echo "Usage:`basename $0` txt"  
	echo "e.g. :"
	echo " `basename $0` bgp.txt"
}
if [ ! -n "$1" ];then
	myhelp
	exit 0
fi
	
	
case $1 in
	-h|--help|help)
	myhelp
	;;
	*)
	main
	;;
esac
