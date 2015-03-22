#!/bin/bash
# rndc 一次清除CNAME缓存
echo "-=-=-=-=-==-=-=-=-=-==-==-=-=-=-=-=-==-=-=-=-=-=-=-="
dig $1 +short
echo "-=-=-=-=-==-=-=-=-=-==-==-=-=-=-=-=-==-=-=-=-=-=-=-="
echo "flush dns cache :"$1
for n in `dig $1 |grep CNAME |sed 's/.*CNAME[[:space:]]*//g'`;do
        echo -e "\E[32;40m\033[1m>>>\033[0m rndc flushname "$n
        rndc flushname $n
done
echo "fluh dns cache done"
echo "-=-=-=-=-==-=-=-=-=-==-==-=-=-=-=-=-==-=-=-=-=-=-=-="
dig $1 +short
echo "-=-=-=-=-==-=-=-=-=-==-==-=-=-=-=-=-==-=-=-=-=-=-=-="
