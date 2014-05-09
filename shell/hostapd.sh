#!/bin/bash
# 开启无线共享
echo "1" > /proc/sys/net/ip/4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
hostapd -B /etc/hostapd/hostapd.conf

