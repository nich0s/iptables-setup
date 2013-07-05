#!/bin/bash
# nc <ssh_host> 7860
# ssh <ssh_host> -l <user> (within 5 seconds)
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 7860 -m recent --name SSH --set -j DROP
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 5 --name SSH -j ACCEPT
