#!/bin/bash
# 开启无线共享
echo "1" > /proc/sys/net/ip/4/ip_forward
hostapd -B /etc/hostapd/hostapd.conf

