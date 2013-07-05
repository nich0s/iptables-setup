#/bin/bash
ipt="/sbin/iptables"
$ipt -F
$ipt -F INPUT
$ipt -F OUTPUT
$ipt -F FORWARD
$ipt -F -t mangle
$ipt -F -t nat
$ipt -X
$ipt -P INPUT ACCEPT
$ipt -P OUTPUT ACCEPT
$ipt -P FORWARD ACCEPT

## Flood / DOS Protection
# SYN Flood
$ipt -A FORWARD -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m limit --limit 1/sec -j ACCEPT 
$ipt -A FORWARD -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK RST -m limit --limit 1/sec -j ACCEPT 
# "Ping of Death"
$ipt -A FORWARD -p icmp -m icmp --icmp-type 8 -m limit --limit 1/sec -j ACCEPT 
# Allow traffic from eth1
$ipt -A FORWARD -i eth1  -j ACCEPT
# Allow traffic from the loopback adapter
$ipt -A INPUT -i lo -j ACCEPT 
# Remote Tech Support (SSH)
$ipt -A INPUT -m tcp -p tcp --dport 22 -s 10.6.4.0/24 -j ACCEPT
# Allow incoming DNS queries
$ipt -A INPUT -m tcp -p tcp --dport 53 -s 10.6.4.0/24 -j ACCEPT
$ipt -A INPUT -m udp -p udp --dport 53 -s 10.6.4.0/24 -j ACCEPT
# Allow established connections
$ipt -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
$ipt -A INPUT -i eth1 -p icmp -m icmp --icmp-type any -j ACCEPT
# Allow local subnet ping
$ipt -A INPUT -p icmp -m icmp --icmp-type any -s 10.6.4.0/24 -j ACCEPT
# Allow munin probe to communicate with nsdcmon01
$ipt -A INPUT -p tcp -m state -m tcp --state NEW -s 10.6.4.18 --dport 4949 -j ACCEPT
## Port knocks
# SSH to nsdcnet02
$ipt -A INPUT -m state --state NEW -m tcp -p tcp --dport 64212 -m recent --name SSH --set -j DROP
$ipt -A INPUT -m state --state NEW -m tcp -p tcp --dport 64213 -m recent --name RDP --set -j DROP
# Drop everything else
$ipt -A INPUT -j DROP
## Port forwarding rules
# Forward SSH traffic originating from eth0 to 10.6.4.13 (nsdcnet02) on port 22 which has been opened by a previous knock rule.
$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 22 -m recent --rcheck --seconds 2 --name SSH -j DNAT --to-destination 10.6.4.13:22
# Pics
#$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 10.6.4.14:8080
# Port forwarding for nsdcxbox01
$ipt --table nat --append PREROUTING -i eth0 -p udp -m udp --dport 88 -j DNAT --to-destination 10.6.4.30:88
$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 3074 -j DNAT --to-destination 10.6.4.30:3074
$ipt --table nat --append PREROUTING -i eth0 -p udp -m udp --dport 3074 -j DNAT --to-destination 10.6.4.30:3074
# End port forwarding for nsdcxbox01
# RDP port forwarding to nsdcwin01 at alternate port 6636
#$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 21 -m recent --rcheck --seconds 2 --name RDP -j DNAT --to-destination 10.6.4.15:3389
# VPN port forwarding to 1194 on nsdcnet02
#$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 1194 -j DNAT --to-destination 10.6.4.17:1194
#$ipt --table nat --append PREROUTING -i eth0 -p udp -m udp --dport 1194 -j DNAT --to-destination 10.6.4.17:1194
#$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 943 -j DNAT --to-destination 10.6.4.13:943
# Vent (temporary until VPN is installed)
$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 3784 -j DNAT --to-destination 10.6.4.14:3784
$ipt --table nat --append PREROUTING -i eth0 -p udp -m udp --dport 3784 -j DNAT --to-destination 10.6.4.14:3784
$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 3785 -j DNAT --to-destination 10.6.4.21:3784
$ipt --table nat --append PREROUTING -i eth0 -p udp -m udp --dport 3785 -j DNAT --to-destination 10.6.4.21:3784
# TOR Exit Node
#$ipt --table nat --append PREROUTING -i eth0 -p tcp -m tcp --dport 9001 -j DNAT --to-destination 10.6.4.14:9001
# Network Address Transation
$ipt --table nat --append POSTROUTING -o eth0 -j MASQUERADE
/sbin/iptables-save > /etc/sysconfig/iptables
/sbin/service iptables restart

