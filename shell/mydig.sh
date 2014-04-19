#!/bin/bash
#ver 2012.9 sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

DNS=(175.188.160.254
175.188.160.154
)
NAME=(
sjz-ck
sjz-ck
)
n=0
long () {
		for url in $i;do
		echo "****************"
		echo -e "\E[01;31m\033[1m$url\033[0m"

			for  D in ${DNS[@]};do
				echo "****************"
				echo -e "\E[32;40m\033[1m$D-${NAME[$n]}>>>\033[0m"
				dig $url @$D > /tmp/mydig.tmp
				sed -n '/ANSWER SECTION/,/^$/p' /tmp/mydig.tmp |sed -e  's/;; ANSWER SECTION://g' -e '/^$/d'
				grep ';; Query time:' /tmp/mydig.tmp 
			
				echo ""
				let n+=1
			done 

		done 
}
short () {
		for url in $i;do
			echo "****************"
			echo -e "\E[01;31m\033[1m$url\033[0m"
			for  D in ${DNS[@]};do
				echo "****************"
				echo -e "\E[32;40m\033[1m$D-${NAME[$n]}>>>\033[0m"
				dig +short $url @$D 
				echo ""
				let n+=1
			done 

		done 
}
help () {
	echo "Usage:`basename $0` [-l] url"  
	echo "e.g. :"
	echo " `basename $0` www.google.com"
	echo " `basename $0` -s www.google.com"
}
if [ -e "/usr/bin/dig" ];then
	case $1 in
		-l|-long)
		shift
		for i in $@;do
		long
		done
		;;
		help|-h|--help)
		help
		;;
		*)
		for i in $@;do
		short	
		done
		;;
	esac
else
	echo "#install dig# "
	echo "RatHat/Centos:"
	echo "#yum install bind-utils"
	echo "Gentoo:"
	echo "#emerge bind-tools"
fi
