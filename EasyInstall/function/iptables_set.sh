#!/bin/bash

INSTALL_BASE_PACKAGES iptables

ETHERNET_CHECK(){
	Eths=${ifconfig|awk '!/^ |^$|lo/ {print $1}'}
	if [ "$Eths" == '' ] ; then
		echo "No effective ethernet , please setup the ethernet ."
		exit 1
	fi
}

IPTABLES_BASE_SET(){
	[ ! -d $ScriptPath/backup ] && mkdir $ScriptPath/backup
	iptables-save > $ScriptPath/backup/iptables.up.rules.backup$(date +"%Y%m%d")
	iptables -F
	iptables -t nat -F
	iptables -X
	iptables -t nat -X
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -p tcp --dport ssh -j ACCEPT
	iptables -A INPUT -j DROP
}

IPTABLES_INPUT_SET(){
	ETHERNET_CHECK
	iptables -I INPUT 3 -p tcp -m multiport -dport $1 -j ACCEPT
}