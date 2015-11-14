#!/usr/bin/env bash
#verison 2015-11-14
#https://github.com/s-h/mytools/shell/check.sh

set -f
TXT=$1
tag2=(
x.x.x.x#BGP
)
tag3=(
x.x.x.x#BGP-NAT-178
x.x.x.x#BGP-NAT-206
)

function color_red (){
echo -e "\E[01;31m\033[1m $1 \033[0m"
}

trace () {
        dos2unix $TXT &>/dev/null
        sed -i "/^\s*$/d" $TXT
        for ip in $i ;do
                traceroute -n -m 4 $ip > /tmp/tracert.txt
                TxtTag2=`grep " 2  " /tmp/tracert.txt |sed -e 's/ 2  //g' -e 's/\s.*//g'`
                TxtTag3=`grep " 3  " /tmp/tracert.txt |sed -e 's/ 3  //g' -e 's/\s.*//g'`
                for i in ${tag2[@]};do
                        tag_ip_2=`echo $i|sed 's/#.*//g'`
                        tag_description_2=`echo $i|sed 's/.*#//g'`
                        if [ $TxtTag2 == $tag_ip_2 ];then
                                txt2=`color_red $tag_description_2`
                        else
                                txt2=$TxtTag2
                        fi
                done
                for i in ${tag3[@]};do
                        tag_ip_3=`echo $i|sed 's/#.*//g'`
                        tag_description_3=`echo $i|sed 's/.*#//g'`
                        if [ $TxtTag3 == $tag_ip_3 ];then
                                txt3=`color_red $tag_description_3`
                        else
                                txt3=$TxtTag3
                        fi

                done
                echo "$ip --> $txt2 -->$txt3"
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
