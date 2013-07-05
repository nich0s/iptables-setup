#!/bin/bash
HOST_IP="192.168.1.148"

/sbin/iptables -N INTO-PHASE2
/sbin/iptables -A INTO-PHASE2 -m recent --name PHASE1 --remove
/sbin/iptables -A INTO-PHASE2 -m recent --name PHASE2 --set
/sbin/iptables -A INTO-PHASE2 -j LOG --log-prefix "INTO PHASE2: "

/sbin/iptables -N INTO-PHASE3
/sbin/iptables -A INTO-PHASE3 -m recent --name PHASE2 --remove
/sbin/iptables -A INTO-PHASE3 -m recent --name PHASE3 --set
/sbin/iptables -A INTO-PHASE3 -j LOG --log-prefix "INTO PHASE3: "

/sbin/iptables -N INTO-PHASE4
/sbin/iptables -A INTO-PHASE4 -m recent --name PHASE3 --remove
/sbin/iptables -A INTO-PHASE4 -m recent --name PHASE4 --set
/sbin/iptables -A INTO-PHASE4 -j LOG --log-prefix "INTO PHASE4: "

/sbin/iptables -N INTO-PHASE5
/sbin/iptables -A INTO-PHASE5 -m recent --name PHASE4 --remove
/sbin/iptables -A INTO-PHASE5 -m recent --name PHASE5 --set
/sbin/iptables -A INTO-PHASE5 -j LOG --log-prefix "INTO PHASE5: "

/sbin/iptables -A INPUT -m recent --update --name PHASE1

/sbin/iptables -A INPUT -p tcp --dport 1172 -m recent --set --name PHASE1
/sbin/iptables -A INPUT -p tcp --dport 1039 -m recent --rcheck --name PHASE1 -j INTO-PHASE2
/sbin/iptables -A INPUT -p tcp --dport 1138 -m recent --rcheck --name PHASE2 -j INTO-PHASE3
/sbin/iptables -A INPUT -p tcp --dport 1027 -m recent --rcheck --name PHASE3 -j INTO-PHASE4
/sbin/iptables -A INPUT -p tcp --dport 1155 -m recent --rcheck --name PHASE4 -j INTO-PHASE5

/sbin/iptables -A INPUT -p tcp -s $HOST_IP --dport 808 -m recent --rcheck --seconds 5 --name PHASE5 -j ACCEPT
