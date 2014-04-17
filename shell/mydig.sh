#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

DNS=(175.188.160.254
175.188.160.154
202.99.160.68
202.106.0.20
222.222.222.222)

if [ -e "/usr/bin/dig" ]
then
        for url in $*;do
        echo "****************"
        echo -e "\E[01;31m\033[1m$url\033[0m"

                for  D in "${DNS[@]}";do
                        echo "****************"
                        echo -e "\E[32;40m\033[1m$D>>>\033[0m"
                        dig $url @$D +short
                        echo ""
                done

        done
else
        echo "dig :command not found"
        echo "RatHat:"
        echo "#yum install bind-utils"
        echo "Gentoo:"
        echo "#emerge bind-tools"
fi
