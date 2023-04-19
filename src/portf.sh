#!/bin/bash


###########################
# User Configurable Section
###########################

IPT=iptables

# Port Forward Server's Localhost
SRC_IP=10.0.0.23

# Final Destination Server now in user configuration file
# FWD_IP=10.0.0.8

# user configuration file
SERVICES="./forward.conf"


############################
# Implementation Section
############################

cleanUp() {
        echo "Flushing Tables. . ."

        # Reset Default Policies
        $IPT -P INPUT ACCEPT
	$IPT -P FORWARD ACCEPT
	$IPT -P OUTPUT ACCEPT
        $IPT -t nat -P PREROUTING ACCEPT
        $IPT -t nat -P POSTROUTING ACCEPT
        $IPT -t nat -P OUTPUT ACCEPT

        # Flush Rules
        $IPT -F
        $IPT -t nat -F

        # Erase non-default chains
        $IPT -X
        $IPT -t nat -X
}

if [ "$1" = "stop" ]
then
        cleanUp
        echo "Firewall rules and chains flushed! Now running with no firewall."
        exit 0
fi

cleanUp

cat $SERVICES | sed -e "s/:/ /" | while read listen ip port;
do
	$IPT -t nat -A PREROUTING -i wlan0 -p tcp --dport $listen -j DNAT --to-destination $ip:$port
	$IPT -t nat -A POSTROUTING -o wlan0 -p tcp --dport $port -d $ip -j SNAT --to-source $SRC_IP
done

echo "Port Forwading Server up and running."
