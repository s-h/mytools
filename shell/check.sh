#!/usr/bin/env bash
set -f
cd /root/kong
TXT=/root/bgp.txt
dos2unix $TXT &>/dev/null
sed -i "/^\s*$/d" $TXT

trace () {
	for ip in $i ;do
        traceroute -n -m 4 $ip > /tmp/tracert.txt
        txt=`grep " 3  " /tmp/tracert.txt |sed -e 's/ 3  //g' -e 's/\s.*//g'`
        if [ $txt = 10.115.239.9 ];then
                echo "$ip ----> BGP"
	elif [ $txt = 14.197.242.57 ];then
                echo "$ip ----> 大网"
        elif [ $txt = 14.197.242.33 ];then
                echo "$ip ----> 大网"
        elif [ $txt = 14.197.250.69 ];then
                echo "$ip ----> 大网"
        elif [ $txt = 10.40.0.178 ];then
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
case $1 in
	-h|--help|help)
	echo ...
	;;
	*)
	main
	;;
esac
