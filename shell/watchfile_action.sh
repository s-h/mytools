#!/usr/bin/env bash
# 使用inotifywait持续监控文件写入变化，触发后续动作，可联动ansible
# yum install inotify-tools
while true;do
        inotifywait dist.zip |grep -i modify && sleep 5 && sh action.sh
done