#! Encoding UTF-8

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
			echo "--------------------------------------------------"
			count=$(expr $count + 1)
		done
	fi
}

RAM_VALUES(){
	RamTotal=$(free $2 | grep 'Mem' | awk '{print $2}')
	RamSwap=$(free $2 | grep 'Swap' | awk '{print $2}')
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
			echo "--------------------------------------------------"
			count=$(expr $count + 1)
		done
	fi
}
HDD_VALUES(){
	declare -a HddPartition
	declare -a HddVolume
	declare -a HddUsed
	declare -a HddUsable
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
			echo "--------------------------------------------------"
			count=$(expr $count + 1)
		done
	fi
}
NET_VALUES(){
	declare -a InterfacesLists
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
				Ip4=$(ifconfig -a $var|awk -F':' '/inet addr/ {print $2}'|awk '{print $1}')
				Ip6=$(ifconfig -a $var|awk '/inet6 addr/ {print $3}')
			fi
			echo -e "${InterfacesLists[$count]} :\n\t ipv4 = $Ip4 \n\t ipv6 = $Ip6"
			echo "--------------------------------------------------"
			count=$(expr $count + 1)
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
			echo "--------------------------------------------------"
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
		VarLists=("返回首页" "打印系统简报" "输出系统目前负载")
	else
		echo "[Notice] Which report created:"
		VarLists=("back" "Print_system's_report" "Echo_System_loading")
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
				echo "Nothing to do";;
			${VarLists[0]})
				SELECT_RUN_SCRIPT;;
		esac
	done
}

