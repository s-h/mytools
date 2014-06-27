#!/bin/bash
NAT_IP_POOL=
DEV_LAN=eth0
DEV_WAN=eth1
GW_LAN=
SSH_PORT=22

useradd=(
10.41.0.0/16
)
sshadd=(
172.16.1.0/24
)
init () {
	if [ -e /proc/sys/net/netfilter/nf_conntrack_max ]; then
		echo 268435456 > /proc/sys/net/netfilter/nf_conntrack_max
		echo 300 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
		echo 10 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_syn_sent
		echo 300 > /proc/sys/net/netfilter/nf_conntrack_udp_timeout_stream
		echo 120 > /proc/sys/net/netfilter/nf_conntrack_udp_timeout
	else
		echo 268435456 > /proc/sys/net/ipv4/netfilter/ip_conntrack_max
		echo 300 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established
		echo 10 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_syn_sent
		echo 300 > /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout_stream
		echo 120 > /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout
	fi
        echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
        echo 1 >  /proc/sys/net/ipv4/ip_forward
        iptables -t filter -F
	modprobe ip_nat_pptp		#支持pptp透传
        for ipmask in "${useradd[@]}";do
                route add -net $ipmask gw $GW_LAN dev $DEV_LAN
                iptables -t nat -A POSTROUTING -s $ipmask -o $DEV_WAN -j SNAT --to-source $NAT_IP_POOL
        done
        sshstart
}
sshstart () {
        for sship in "${sshadd[@]}";do
                iptables -A INPUT -s $sship -p tcp -m state --state NEW -m tcp --dport $SSH_PORT -j ACCEPT
        done
        }
natstart() {
        for ipmask in "${useradd[@]}";do
                iptables -t nat -A POSTROUTING -s $ipmask -o $DEV_WAN -j SNAT --to-source $NAT_IP_POOL
        done

        }
add () {

        read -p "Enter new user address e.g. 192.168.1.0/24:  " nadd
        route add -net $nadd gw $GW_LAN dev $DEV_LAN
        iptables -t nat -A POSTROUTING -s $nadd -o $DEV_WAN -j SNAT --to-source $NAT_IP_POOL
        }
del () {

        read -p "Enter del user address e.g. 192.168.1.0/24:  " ndel
        route del -net $ndel gw $GW_LAN dev $DEV_LAN
        iptables -t nat -D POSTROUTING -s $ndel -o $DEV_WAN -j SNAT --to-source $NAT_IP_POOL
        }

help () {
        echo "Usage: $0 [init|natstart|add|del|sh]"
        }
case $1 in
        init)
        init ;;
        add)
        add ;;
        del)
        del;;
        natstart)
        natstart ;;
        sshstart)
        sshstart ;;
        *)
        help ;;
esac

