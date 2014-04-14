#!/usr/bin/env bash
TXT=bgp.txt
dos2unix $TXT &>/dev/null
sed -i "/^\s*$/d" $TXT

trace () {
	for ip in $i ;do
        traceroute -n -m 4 $ip > tracert.txt
        n=`grep " 3  " tracert.txt |sed -e 's/ 3  //g' -e 's/\s.*//g'`
        if [ $n = 10.10.233.42 ];then
                echo "$ip ----> 电信200M"
        elif [ $n = 10.10.233.14 ];then
                echo "$ip ----> 开发区"
        elif [ $n = 10.154.8.45 ];then
                echo "$ip ----> 默认"
        elif [ $n = 10.10.233.82 ];then
                echo "$ip ----> 铁通"
        elif [ $n = 10.10.233.114 ];then
                echo "$ip ----> 北京联通2（233.114）"
        elif [ $n = 10.10.233.110 ];then
                echo "$ip ----> 北京联通1（233.110）"
        elif [ $n = 14.197.242.57 ];then
                echo "$ip ----> 大网"
        elif [ $n = 14.197.242.33 ];then
                echo "$ip ----> 大网"
        elif [ $n = 10.115.239.9 ];then
                echo "$ip ----> BGP"
        else
                echo "$ip ----> $n"
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
mainnoname () {
while read i;do
	if [[ "$i" =~ "##" ]];then
		echo $i
	elif [[ "$i" =~ "#" ]];then
		echo >/dev/null
	else
		for ip in $i ;do
		traceroute -n -m 4 $ip > tracert.txt 		
		n=`grep " 3  " tracert.txt|sed 's/ 3  //g'`
		echo "$ip  ----> $n"
		done

	
	fi
done < $TXT
}
case $1 in
	-h|--help|help)
	echo ...
	;;
	-n|--noname)
	mainnoname
	;;
	*)
	main
	;;
esac
