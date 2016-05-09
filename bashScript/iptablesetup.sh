#!/bin/bash
#########################################################################
# NOTE:
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2014
#########################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

ScriptPath=$(cd $(dirname "$0") && pwd)
cn="false"
case $LANG in
	zh_CN*) cn="true";;
esac
#检测需要的程序
IptablesTools=iptables
Conf=iptables.conf
EXIT_LOG(){
	$cn && ExitLog="$1" || ExitLog="$2"
	echo "$(date +%Y-%m-%d-%H:%M) -ERR $ExitLog"|tee $ScriptPath/err.log && exit 1
}

for tmp in $IptablesTools;do
	[[ -z $(which $tmp) ]] && EXIT_LOG "系统缺少运行本程序的命令，请先安装相应的命令:$tmp" "please install the corresponding command:$tmp"
done

[ -f $ScriptPath/$Conf ] && source $ScriptPath/$Conf || EXIT_LOG "无法访问$Conf: 没有那个文件" "cannot access :$Conf No such file"


IPTABLES_BASE_SET(){
	for var in $IptablesTools; do
		$var -F
		$var -t nat -F
		$var -X
		$var -P INPUT DROP
		$var -P OUTPUT ACCEPT
		$var -P FORWARD ACCEPT
		$var -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 10 -j ACCEPT
		$var -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
		$var -A INPUT -i lo -j ACCEPT
		$var -A OUTPUT -o lo -j ACCEPT
		$var -A INPUT -p tcp --dport ssh -j ACCEPT
	done
}
PORT_OPEN(){
	for var in $IptablesTools; do
		if [[ $(echo $2|awk -F',' '{print NF}') -gt 1 ]] ;then
			$var -A INPUT -i $1 -p tcp -m multiport --dport $2 -j ACCEPT
		else
			$var -A INPUT -i $1 -p tcp --dport $2 -j ACCEPT
		fi
	done
}

NAT_FORWARD(){
	for var in $IptablesTools; do
		$var -t nat -A PREROUTING -i $outsidenetdev -p tcp -d $1 --dport $2 -j DNAT --to-destination $3:$4
	done
}
NAT_FORWARD_SETUP(){
	sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
	sysctl -p
	for var in $IptablesTools;do
		$var -A FORWARD -i $outsidenetdev -o $insidenetdev -m state --state ESTABLISHED,RELATED -j ACCEPT
		$var -A FORWARD -i $insidenetdev -o $outsidenetdev -m state --state ESTABLISHED,RELATED -j ACCEPT
		$var -t nat -A POSTROUTING -p tcp -j MASQUERADE
	done
	for tmp in $(echo $netforwardlists|sed 's/;/ /g');do
		NAT_FORWARD $(echo $tmp|sed 's/,/ /g')
	done
}
IPTABLES_BASE_SET
[[ -n $outsideports ]] && PORT_OPEN $outsidenetdev $outsideports
[[ -n $insideports ]] && PORT_OPEN $insidenetdev $insideports
[[ -n $netforwardlists ]] && NAT_FORWARD_SETUP