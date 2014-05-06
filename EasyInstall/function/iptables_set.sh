#!/bin/bash
#安装iptables,检测网卡
ETHERNET_CHECK(){
	INSTALL_BASE_PACKAGES iptables
	Eths=`ifconfig|awk '!/^ |^$|lo/ {print $1}'`
	if [ "$Eths" == '' ] ; then
		echo "No effective ethernet , please setup the ethernet ."
		exit 1
	fi
}
#iptables的基本设置和备份
IPTABLES_BASE_SET(){
	[ ! -d $ScriptPath/backup ] && mkdir $ScriptPath/backup
	for var in iptables ip6tables ; do
		$var-save > $ScriptPath/backup/$var.up.rules.backup$(date +"%Y%m%d")
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
#增加放行端口的规则
IPTABLES_INPUT_SET(){
	for var in iptables ip6tables ; do
		$var -A INPUT -p tcp -m multiport --dport $1 -j ACCEPT
	done
}
#输入需要放行的有效的端口号
IPTABLES_SET_PORT(){
	InputPorts=""
	InputPort=""
	while true ;do
		echo "For every input port and then press enter to enter another, input 'r' or 'R' reset input, input 'n' of 'N' exit"
		read InputPort
		case $InputPort in
			[1-9][0-9]*)
				if [ $InputPort -ge 65535 ];then
					echo "the port number is illegal, please input again."
				else
					tmp=$InputPorts
					[[ "$InputPorts" == '' ]] && InputPorts=$InputPort || InputPorts=$InputPort,$tmp
				fi
				;;
			n|N)
				break;;
			r|R)
				InputPorts="";;
			*)
				echo "input is not number, please input again";;
		esac
		echo "your port number is $InputPorts"
	done
	[[ "$InputPorts" == '' ]] && echo "nothing to do" || IPTABLES_INPUT_SET $InputPorts
	echo "$InputPorts is setup in iptables"
	PASS_ENTER_TO_EXIT
}
SELECT_IPTABLES_FUNCTION(){
	clear;
	echo "[Notice]How to set up iptables:"
	select var in "Check iptables rules and status" "Setup iptables" "Add rules" "back";do
		case $var in
			"Check iptables rules and status")
				iptables -L -n -v
				ip6tables -L -n -v
				PASS_ENTER_TO_EXIT;;
			"Setup iptables")
				ETHERNET_CHECK && IPTABLES_BASE_SET;;
			"Add rules")
				IPTABLES_SET_PORT;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_IPTABLES_FUNCTION;;
		esac
		break
	done
}