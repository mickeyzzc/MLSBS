#! Encoding UTF-8
shopt -s extglob
IPTABLES_VAR(){
	Protocol=
	MyChain=
	MyInterface=
	IptablesTools="iptables ip6tables"
	IptableStat=
	SourceNet=
	SPortRange=
	DesNet=
	DPortRange=
}
#iptables的基本设置和备份
IPTABLES_BASE_SET(){
	INSTALL_BASE_PACKAGES iptables
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
INTERFACE_CHOOSE(){
	[[ -z "$(which ifconfig)" ]] && Interfaces=$(ip link|awk -F':' '!/^ |lo/ {print $2}'|sed 's/^ //g')|| Interfaces=$(ifconfig|awk '!/^ |^$|lo/ {print $1}')
	if [[ -z "$Interfaces" ]] ; then
		EXIT_MSG "没有发现已启动的网卡,请启动后再运行此程序." "No effective ethernet , please setup the ethernet ."
	fi
	INPUT_CHOOSE $Interfaces "lo" "all"
	[ -z "$VarTmp" -o "$VarTmp" == "all" ] && MyInterface="" || MyInterface="-i $var"

}
IPTABLES_CHAINS_CHOOSE(){
	MyChains="INPUT OUTPUT FORWARD PREROUTING POSTROUTING"
	INPUT_CHOOSE $MyChains
	[[ -n "$VarTmp" ]] && MyChain=$VarTmp || IPTABLES_CHAINS_CHOOSE
}
IPTABLES_PROTOCOL_SET(){
	Protocols="icmp tcp udp ah udplite sctp dccp"
	INPUT_CHOOSE $Protocols
	[[ -n "$VarTmp" ]] && Protocol="-p $VarTmp" || IPTABLES_PROTOCOL_SET
}
#输入需要有效的端口号
IPTABLES_SET_PORT(){
	InputPorts=""
	InputPort=""
	$cn && TmpMsg="每次输入完一个端口号后按回车接着输入下一个端口,按'r'或者'R'重置输入,按'a'或者'A'跳过端口号的输入,按'n'或者'N'结束当前输入."  || TmpMsg="For every input port and then press enter to enter another, input 'r' or 'R' reset input, input 'a' of 'A' choose all port, input 'n' of 'N' exit : "
	while true ;do
		read -p "$TmpMsg" InputPort
		case $InputPort in
			[1-9][0-9]*)
				if [[ $InputPort -ge 65535 ]];then
					INFO_MSG "你输入的是非法端口,请重新输入." "the port number is illegal, please input again."
				else
					tmp=$InputPorts
					[[ -z "$InputPorts" ]] && InputPorts=$InputPort || InputPorts=$InputPort,$tmp
				fi
				;;
			a|A)
				InputPorts=""
				break;;
			n|N)
				break;;
			r|R)
				InputPorts="";;
			*)
				INFO_MSG "你输入的是无效端口,请重新输入" "input is not number, please input again";;
		esac
		INFO_MSG "你输入的端口号是 : $InputPorts " "your port number is $InputPorts"
	done
	$cn && TmpMsg="你要设置的端口号 : $InputPorts "  || TmpMsg="$InputPorts is setup in iptables"
	#[ -z $InputPorts ] && echo "nothing to do" || IPTABLES_INPUT_SET $InputPorts
	read -p "$TmpMsg" -t 5 ok
}
IPTABLES_SET_IP(){
	InputIp=""
	ext4ip="[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]"
	$cn && TmpMsg="请输入要有效的IP4地址按回车结束,如果要重新输入请输入一个错误的IP4地址然后回车,请按'n'和'N'跳过输入."  || TmpMsg="Please input a valid IP and then press enter, input err ip to reset input, input 'n' of 'N' exit : "
	while true ;do
		read -p "$TmpMsg" InputIp
		case $InputIp in
			@($ext4ip).@($ext4ip).@($ext4ip).@($ext4ip))
				IptablesTools="iptables"
				break;;
			@($ext4ip).@($ext4ip).@($ext4ip).@($ext4ip)-@($ext4ip))
				IptablesTools="iptables"
				break;;
			@($ext4ip).@($ext4ip).@($ext4ip).@($ext4ip)/@([1-9]|[12][0-9]|3[0-2]))
				IptablesTools="iptables"
				break;;
			n|N)
				InputIp=""
				break;;
			*)
				INFO_MSG "输入的IP地址无效,请重新输入:" "input is not valid ip, please input again";;
		esac
	done
}
IPTABLES_STATUS_SET(){
	IpStatus="ACCEPT DROP"
	INPUT_CHOOSE $IpStatus
	[[ -n $VarTmp ]] && IptableStat="-j $VarTmp" || IPTABLES_STATUS_SET
}
#增加防火墙的规则
IPTABLES_INPUT_SET(){
	IPTABLES_VAR
	echo "#############################################"
	echo "#which interface are you choose?"
	echo "#############################################"
	INTERFACE_CHOOSE
	echo "#############################################"
	echo "#which chains are you choose?"
	echo "#############################################"
	IPTABLES_CHAINS_CHOOSE
	echo "#############################################"
	echo "#which protocol are you choose?"
	echo "#############################################"
	IPTABLES_PROTOCOL_SET
	echo "#############################################"
	echo "#which source ip are you choose?"
	echo "#############################################"
	IPTABLES_SET_IP
	[[ -n "$InputIp" ]] && SourceNet="-s $InputIp" || SourceNet=""
	echo "#############################################"
	echo "#which source port are you choose?"
	echo "#############################################"
	IPTABLES_SET_PORT
	[[ -n "$InputPorts" ]] && SPortRange="--sport $InputPorts" || SPortRange=""
	echo "#############################################"
	echo "#which destination ip are you choose?"
	echo "#############################################"
	IPTABLES_SET_IP
	[[ -n "$InputIp" ]] && DesNet="$InputIp" || DesNet=""
	echo "#############################################"
	echo "#which destination port are you choose?"
	echo "#############################################"
	IPTABLES_SET_PORT
	[[ -n "$InputPorts" ]] &&	DPortRange="--dport $InputPorts" || DPortRange=""
	echo "#############################################"
	echo "#which status are you choose?"
	echo "#############################################"
	IPTABLES_STATUS_SET
	for var in $IptablesTools ; do
		if [ "$(echo $SPortRange|grep ',')" -o "$(echo $DPortRange|grep ',')" ] ; then
			ModuleName="-m multiport"
			until [ "$Protocol" == "-p tcp" -o "$Protocol" == "-p udp" -o "$Protocol" == "-p udplite" -o "$Protocol" == "-p sctp" -o "$Protocol" == "-p dccp" ] ; do
					echo "#############################################"
					echo "#You must choose the protocol with '-p tcp, -p udp, -p udplite, -p sctp or -p dccp'!"
					echo "#############################################"
					IPTABLES_PROTOCOL_SET
			done
		else
			ModuleName=""
		fi
		read -p "$var $1 $MyChain $Protocol $MyInterface $ModuleName $SourceNet $SPortRange $DesNet $DPortRange $IptableStat" -t 5 ok
		$var $1 $MyChain $Protocol $MyInterface $ModuleName $SourceNet $SPortRange $DesNet $DPortRange $IptableStat
	done
}
SELECT_IPTABLES_FUNCTION(){
	clear;
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择需要的功能:"
		VarLists=("返回首页" "查看防火墙规则" "初始化防火墙默认配置" "增加防火墙的规则" "删除防火墙的规则")
	else
		echo "[Notice]How to set up iptables:"
		VarLists=("back" "Check_iptables_rules_and_status" "Setup_iptables" "Add_rules" "Del_rules")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				iptables -L -n -v
				ip6tables -L -n -v
				PASS_ENTER_TO_EXIT;;
			${VarLists[2]})
				IPTABLES_BASE_SET;;
			${VarLists[3]})
				IPTABLES_INPUT_SET "-A";;
			${VarLists[4]})
				IPTABLES_INPUT_SET "-D";;			
			${VarLists[0]})
				SELECT_RUN_SCRIPT;;
		esac
	done
}
