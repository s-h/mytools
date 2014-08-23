#!/bin/bash
# 子接口ip ping检测
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
source="x.x.x"
test_ip="202.99.160.68"
for sitenu in $(seq 33 62)
do
        ping -c 1 -w 1 -I ${source}.${sitenu} $test_ip &> /dev/null && result=0 || result=1
        if [ "$result" == 0 ]; then
                echo "IP ${source}.${sitenu} is OK."
        else
                echo "IP ${source}.${sitenu} is false."
        fi
done
