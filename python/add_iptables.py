#!/usr/bin/env python 
# -*- coding: utf-8 -*
#https://github.com/s-h/mytools
import commands
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-t","--tcp",type="string",dest="tcpPort")
parser.add_option("-u","--udp",type="string",dest="udpPort")
parser.add_option("-l","--log",action="store_true",dest="log")
parser.add_option("-T","--localtcp",action="store_true",dest="localtcp")
parser.add_option("-U","--localudp",action="store_true",dest="localudp")
(options,args) = parser.parse_args()

def printTcpRule(tcpport):
    for i in tcpport:
        print "iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport " + i + " -j ACCEPT" 
def printUdpRule(udpport):
    for i in udpport:
        print "iptables -A INPUT -p udp --dport " + i + " -j ACCEPT" 
def getTcpPort():
    (status,output) = commands.getstatusoutput("netstat -anp 2>/dev/null|grep LISTEN |grep ^tcp| gawk '{print $4}'|gawk '{match($0,/([0-9]*$)/,a);print a[1]}' |sort -n|uniq")
    return output

def getUdpPort():
    (status,output) = commands.getstatusoutput("netstat -anp 2>/dev/null|grep ^udp| gawk '{print $4}'|gawk '{match($0,/([0-9]*$)/,a);print a[1]}' |sort -n|uniq")
    return output

def init():
    print """iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT  
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT"""

    if options.tcpPort is not None:
        tcpPort = options.tcpPort.split(',')
        printTcpRule(tcpPort)
    if options.udpPort is not None:
        udpPort = options.udpPort.split(',')
        printUdpRule(udpPort)

    if options.localtcp is True:
        localTcpPort = getTcpPort().split()
        if localTcpPort:
            printTcpRule(localTcpPort)
    if options.localudp is True:
        localUdpPort = getUdpPort().split()
        if localUdpPort:
            printUdpRule(localUdpPort)
    if options.log is True:
        print "iptables -A INPUT -m state --state INVALID -j LOG --log-prefix 'iptables-INVALID-log:'"
        print "iptables -A INPUT -j LOG --log-prefix 'iptables-drop-log:'"

    if options.log is not True:
        print """iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited 
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited"""

init()
