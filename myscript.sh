#!/usr/bin/env bash
#! Encoding UTF-8
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
#获取脚本路劲
ScriptPath=$(cd $(dirname "$0") && pwd)
#加载配置内容
source $ScriptPath/config
#################错误提示##############################
cn="false"
case $LANG in
	zh_CN*) cn="true";;
esac
EXIT_MSG(){
	$cn && ExitMsg="$1" || ExitMsg="$2"
	echo "$(date +%Y-%m-%d-%H:%M) -ERR $ExitMsg " && exit 1
}
#########普通日志##########
INFO_MSG(){
	$cn && InfoMsg="$1" || InfoMsg="$2"
	echo "$(date +%Y-%m-%d-%H:%M) -INFO $InfoMsg "
}
#检测脚本文件是否存在并加载
SOURCE_SCRIPT(){
for arg do
	if [ ! -f "$arg" ]; then
		EXIT_MSG "缺少文件：$arg ，程序无法运行，请重新下载原程序！" "not exist $arg,so $0 can not be supported!" 
	else
		INFO_MSG "正在加载库: $arg ......" "loading $arg now, continue ......"
		source $arg
	fi
done
}
[[ "$SysName" == '' ]] && EXIT_MSG "程序不支持在此系统上运行。" "Your system is not supported this script"
SOURCE_SCRIPT $LibPath/common
#main
SELECT_RUN_SCRIPT(){
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择要运行的指令:"
		VarLists=("退出" "软件安装" "系统设置" "生成任务")
	else
		echo "[Notice] Which function you want to run:"
		VarLists=("Exit" "Sofeware_Install" "System_Setup" "Create_Cron")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				SOURCE_SCRIPT $FunctionPath/sofeinstall.sh
				SELECT_SOFE_INSTALL;;
			${VarLists[2]})
				SOURCE_SCRIPT $FunctionPath/system_setup.sh
				SELECT_SYSTEM_SETUP_FUNCTION;;
			${VarLists[3]})
				SOURCE_SCRIPT $LibPath/decryption_encryption $FunctionPath/create_cron.sh
				SELECT_ENCRY_FUNCTION
				SELECT_CRON_FUNCTION;;
			${VarLists[0]})
				exit 0;;
			*)
				SELECT_RUN_SCRIPT;;
		esac
		break
	done
	SELECT_RUN_SCRIPT
}
SELECT_RUN_SCRIPT
