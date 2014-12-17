#! Encoding UTF-8
REPORT_MSG(){
	echo "_______________________________"
	$cn && echo "10秒取值一次,请耐心等待.输入任意键后按回车退出;如果你等不及,可以不按任何键的情况下直接按回车立即取值输出." || echo "A value of 10's, please be patient.Input some key and put enter to exit.If you can't wait, you can not directly under the condition of press any key and press enter output value immediately."
	echo "_______________________________"
}
CPU_VALUES(){
	CpuProNum=$(cat /proc/cpuinfo |grep 'processor'|wc -l)
	CpuPhyNum=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
	CpuCoreNum=$(cat /proc/cpuinfo | grep "core id" | uniq | wc -l)
	CpuModel=$(cat /proc/cpuinfo | grep "model name" | uniq|awk -F':' '{print $2}')
	CpuFlags=$(cat /proc/cpuinfo | grep "flags" | uniq|awk -F':' '{print $2}')
	if [[ "$1" == "print" ]];then
		declare -a VarLists
		declare -a ValueLists
		$cn && VarLists=("CPU物理核数" "CPU逻辑核数" "CPU线程数" "CPU类型" "CPU指令支持") || VarLists=("Cpu_physical" "Cpu_core" "Cpu_processor" "Cpu_model" "Cpu_flags")
		ValueLists=("$CpuPhyNum" "$CpuCoreNum" "$CpuProNum" "$CpuModel" "$CpuFlags")
		echo "++++++++++++++++++++++++++++++++++++++"
		echo "#              CPU                   #"
		echo "--------------------------------------"
		count=0
		for var in ${VarLists[@]}; do
			echo -e "${VarLists[$count]} :\n\t ${ValueLists[$count]}"
			echo "_______________________________"
			count=$(expr $count + 1)
		done
	elif [[ "$1" == "report" ]];then
		CpuLoad=($(cat /proc/loadavg | awk '{print $1,$2,$3}'))
		CpuLoad1m=$(echo ${CpuLoad[0]}*100|bc)
		$cn && echo -n -e "CPU负载(1m):${CpuLoad1m%%.*}%\t" || echo -n -e "CPU_Loading(1m):${CpuLoad1m%%.*}%\t"
	fi
}

RAM_VALUES(){
	RamTotal=$(free $2 | grep 'Mem' | awk '{print $2}')
	RamSwap=$(free $2 | grep 'Swap' | awk '{print $2}')
	RamUsed=$(free $2 | awk '/Mem|Swap/ {used+=$3}END{print used}')
	RamUse=$(free $2 | awk '/Mem|Swap/ {total+=$2;use+=$4+$6+$8}END{print total-use}')
	RamSum=$[$RamTotal+$RamSwap]
	if [[ "$1" == "print" ]];then
		declare -a VarLists
		declare -a ValueLists
		$cn && VarLists=("物理内存" "虚拟内存" "总内存") || VarLists=("RAN_TOTAL" "RAN_SWAP" "RAM_SUM")
		ValueLists=("$RamTotal" "$RamSwap" "$RamSum")
		echo "++++++++++++++++++++++++++++++++++++++"
		echo "#              RAM                   #"
		echo "--------------------------------------"
		count=0
		for var in ${VarLists[@]} ;do
			echo -e "${VarLists[$count]} :\n\t ${ValueLists[$count]}"
			echo "_______________________________"
			count=$(expr $count + 1)
		done
	elif [[ "$1" == "report" ]];then
		$cn && echo -n -e "内存总负载:$(echo ${RamUsed}*100/${RamSum}|bc)%\t内存程序使用率:$(echo ${RamUse}*100/${RamSum}|bc)%\t" || echo -n -e "RAM_Loading:$(echo ${{RamUsed}}*100/${RamSum}|bc)%\tRAM_using:$(echo ${RamUse}*100/${RamSum}|bc)%\t"
	fi
}
HDD_VALUES(){
	HddVolume=($(df -P $1 |awk '/^\/dev/ {print $2}'))
	HddPartition=($(df -P $1 |awk '/^\/dev/ {print $NF}'))
	HddUsed=($(df -P $1 |awk '/^\/dev/ {print $3}'))
	HddUsable=($(df -P $1 |awk '/^\/dev/ {print $4}'))
	if [[ "$2" == "print" ]];then
		echo "++++++++++++++++++++++++++++++++++++++"
		[[ "$1" == "-i" ]] && echo "#          HDD  INODES               #" || echo "#            HDD  ZONE               #"
		echo "--------------------------------------"
		count=0
		for var in ${HddPartition[@]} ;do
			echo -e "${HddPartition[$count]} :\n\t ${HddVolume[$count]}"
			echo "_______________________________"
			count=$(expr $count + 1)
		done
	elif [[ "$2" == "report" ]];then
		HddIn=$(awk '/pgpgin/{print $2}' /proc/vmstat)
		HddOut=$(awk '/pgpgout/{print $2}' /proc/vmstat)
	fi
}
NET_VALUES(){
	[[ -z "$(which ifconfig)" ]] && InterfacesLists=($(ip link|awk -F':' '!/^ |lo/ {print $2}'|sed 's/^ //g'))|| InterfacesLists=($(ifconfig|awk '!/^ |^$|lo/ {print $1}'))
	[[ -z "$InterfacesLists" ]] && INFO_MSG "没有有效的网络配置" "No valid networks" 
	if [[ "$1" == "print" ]];then
		echo "++++++++++++++++++++++++++++++++++++++"
		echo "#            NETWORKS                #"
		echo "--------------------------------------"
		count=0
		for var in ${InterfacesLists[@]} ;do
			if [[ -z "$(which ifconfig)" ]];then
				Ip4=$(ip addr show $var|awk '/inet / {print $2}')
				Ip6=$(ip addr show $var|awk '/inet6/ {print $2}')
			else
				Ip4=$(ifconfig -a $var|awk -F'[: ]+' '/inet addr/ {print $4}')
				Ip6=$(ifconfig -a $var|awk '/inet6 addr/ {print $3}')
			fi
			echo -e "${InterfacesLists[$count]} :\n\t ipv4 = $Ip4 \n\t ipv6 = $Ip6"
			echo "_______________________________"
			count=$(expr $count + 1)
		done
	elif [[ "$1" == "report" ]];then
		i=0
		declare -a NetParkets
		declare -a NetBytes
		for var in ${InterfacesLists[@]} ;do
			NetParkets=($(grep "$var" /proc/net/dev|awk -F'[: ]+' 'BEGIN{ORS=" "}{print $4,$12}'))
			NetBytes=($(grep "$var" /proc/net/dev|awk -F'[: ]+' 'BEGIN{ORS=" "}{print $3,$11}'))
			InBytesLists[$i]=${NetBytes[0]}
			OutBytesLists[$i]=${NetBytes[1]}
			InParketsLists[$i]=${NetParkets[0]}
			OutParketsLists[$i]=${NetParkets[1]}
			i=$(expr $i + 1)
		done
	fi
}
OTHER_VALUES(){
	FileMax=$(cat /proc/sys/fs/file-max)
	OSlimit=$(ulimit -n)
}
SYSTEM_PARAMETER(){
	declare -a VarLists
	declare -a ValueLists
	$cn && VarLists=("系统名" "系统架构" "内核版本") || VarLists=("System_name" "System_Bit" "System_var")
	ValueLists=("$SysName" "$SysBit" "$SysVer")
	if [[ "$1" == "print" ]];then
		echo "++++++++++++++++++++++++++++++++++++++"
		echo "#              SYSTEM                #"
		echo "--------------------------------------"
		count=0
		for var in ${VarLists[@]}; do
			echo -e "${VarLists[$count]} :\n\t ${ValueLists[$count]}"
			echo "_______________________________"
			count=$(expr $count + 1)
		done
	fi
}
SELECT_REPORT_CREATE(){
	clear;
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择需要生成的报告:"
		VarLists=("返回首页" "打印系统简报" "输出系统目前负载" "输出网络负载")
	else
		echo "[Notice] Which report created:"
		VarLists=("back" "Print_system's_report" "Echo_System_loading" "Echo_Network_loading")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				SYSTEM_PARAMETER print
				CPU_VALUES print
				RAM_VALUES print -m
				HDD_VALUES -h print
				HDD_VALUES -i print
				NET_VALUES print
				;;
			${VarLists[2]})
				REPORT_MSG
				HDD_VALUES -a report
				HddInTmp=$HddIn
				HddOutTmp=$HddOut
				while true ;do
					CPU_VALUES report
					RAM_VALUES report
					HDD_VALUES -a report
					$cn && echo -n -e "硬盘写入:$[$HddIn-$HddInTmp]\t硬盘读取:$[$HddOut-$HddOutTmp]\t\n" || echo -n -e "HDD IN:$[$HddIn-$HddInTmp]\tHDD OUT:$[$HddOut-$HddOutTmp]\t\n"
					HddInTmp=$HddIn
					HddOutTmp=$HddOut
					read -t 10 ok
					[[ -n "$ok" ]] && break
				done;;
			${VarLists[3]})
				declare -a TmpInBytesLists
				declare -a TmpOutBytesLists
				declare -a TmpInParketsLists
				declare -a TmpOutParketsLists
				REPORT_MSG
				NET_VALUES report
				TmpInBytesLists=(${InBytesLists[@]})
				TmpOutBytesLists=(${OutBytesLists[@]})
				TmpInParketsLists=(${InParketsLists[@]})
				TmpOutParketsLists=(${OutParketsLists[@]})
				while true ; do
					count=0
					NET_VALUES report
					for var in ${InterfacesLists[@]} ;do
						$cn && echo -n -e "$var 流入(bytes):$[${InBytesLists[$count]}-${TmpInBytesLists[$count]}]\t$var 流出(bytes):$[${OutBytesLists[$count]}-${TmpOutBytesLists[$count]}]\t" || echo -n -e "$var In(bytes):$[${InBytesLists[$count]}-${TmpInBytesLists[$count]}]\t$var Out(bytes):$[${OutBytesLists[$count]}-${TmpOutBytesLists[$count]}]\t"
						$cn && echo -n -e "$var 流入(包):$[${InParketsLists[$count]}-${TmpInParketsLists[$count]}]\t$var 流出(包):$[${OutParketsLists[$count]}-${TmpOutParketsLists[$count]}]\t\n" || echo -n -e "$var In(parkets):$[${InParketsLists[$count]}-${TmpInParketsLists[$count]}]\t$var Out(parkets):$[${OutParketsLists[$count]}-${TmpOutParketsLists[$count]}]\t\n"
						count=$(expr $count + 1)
					done
					TmpInBytesLists=(${InBytesLists[@]})
					TmpOutBytesLists=(${OutBytesLists[@]})
					TmpInParketsLists=(${InParketsLists[@]})
					TmpOutParketsLists=(${OutParketsLists[@]})
					echo "-----------------------"
					read -t 10 ok
					[[ -n "$ok" ]] && break
				done;;
			${VarLists[0]})
				SELECT_RUN_SCRIPT;;
		esac
	done
}