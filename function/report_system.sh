#! Encoding UTF-8

CPU_VALUES(){
	CpuProNum=$(cat /proc/cpuinfo |grep 'processor'|wc -l)
	CpuPhyNum=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
	CpuCoreNum=$(cat /proc/cpuinfo | grep "core id" | uniq | wc -l)
	CpuModel=$(cat /proc/cpuinfo | grep "model name" | uniq|awk -F':' '{print $2}')
	CpuFlags=$(cat /proc/cpuinfo | grep "flags" | uniq|awk -F':' '{print $2}')
	if [[ "$1" == "print" ]]
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
	RamTotal=$(free -m | grep 'Mem' | awk '{print $2}')
	RamSwap=$(free -m | grep 'Swap' | awk '{print $2}')
	RamSum=$[$RamTotal+$RamSwap]
	if [[ "$1" == "print" ]]
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
	if [[ "$2" == "print" ]]
		echo "++++++++++++++++++++++++++++++++++++++"
		[[ "$1" == "-i" ]] && echo "#          HDD  INODES               #" || echo "#            HDD  ZONE               #"
		echo "--------------------------------------"
		count=0
		for var in ${HddPartition[@]} ;do
			echo -e "${VarLists[$count]} :\n\t ${ValueLists[$count]}"
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
	$cn && VarLists=("系统名" "系统架构" "CPU") || VarLists=("System_name" "System_Bit" "Download")
}


