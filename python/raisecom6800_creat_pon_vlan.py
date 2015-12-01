#!/usr/bin/env python
solt_start=6
solt_end=8
port_start=1
port_end=12
pevlan_start=3663
for epon_olt_solt in range(solt_start,(solt_end + 1)):
    for epon_olt_port in range(port_start,(port_end + 1)):
        print "interface epon-olt " + str(epon_olt_solt) + "/" + str(epon_olt_port)
        print "vlan dot1q-tunnel"
        print "yes"
        print "onu-svr-template 1 binded-onu-list 1-64"
        print "switchport trunk native vlan " + str(pevlan_start)
        print "switchport trunk allowed vlan " + str(pevlan_start)
        print "yes"
        print "switchport trunk untagged vlan remove 1"
        print "switchport mode trunk"
        print "quit"
        pevlan_start += 1
        
