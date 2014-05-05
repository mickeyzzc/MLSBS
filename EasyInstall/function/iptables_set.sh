#!/bin/bash
#安装iptables
INSTALL_BASE_PACKAGES iptables
#检测网卡
ETHERNET_CHECK(){
	Eths=${ifconfig|awk '!/^ |^$|lo/ {print $1}'}
	if [ "$Eths" == '' ] ; then
		echo "No effective ethernet , please setup the ethernet ."
		exit 1
	fi
}
#iptables的基本设置和备份
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
#增加放行端口的规则
IPTABLES_INPUT_SET(){
	iptables -I INPUT 3 -p tcp -m multiport -dport $1 -j ACCEPT
}
#输入需要放行的有效的端口号
IPTABLES_SET_CONFIG(){
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
				continue
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
}
ETHERNET_CHECK && IPTABLES_BASE_SET && IPTABLES_SET_CONFIG