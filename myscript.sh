#!/bin/bash
# -*- coding:utf-8 -*-
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
	SOURCE_SCRIPT $FunctionPath/system_base_set.sh
	echo "[Notice] Which function you want to run:"
	select var in "Initialize System" "Install nginx" "Install tomcat" "Install Mysql" "Setup firewall" "Install Puppet" "create cron" "Exit";do
		case $var in
			"Initialize System")
				SELECT_SYSTEM_BASE_FUNCTION;;
			"Install nginx")
				SOURCE_SCRIPT $FunctionPath/nginx_install.sh
				NGINX_VAR && SELECT_NGINX_FUNCTION;;
			"Install tomcat")
				SOURCE_SCRIPT $FunctionPath/tomcat_install.sh
				TOMCAT_VAR && SELECT_TOMCAT_FUNCTION;;
			"Install Mysql")
				SOURCE_SCRIPT $FunctionPath/mysql_install.sh
				MYSQL_VAR && MYSQL_BASE_PACKAGES_INSTALL && INSTALL_MYSQL;;
			"Setup firewall")
				if [ ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -ge 13 ];then
					read -p "wait my script update" -t 5 ok
				elif [ ${SysVer%%.*} -eq 2 -o ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -le 12 ];then
					SOURCE_SCRIPT $FunctionPath/iptables_set.sh
					SELECT_IPTABLES_FUNCTION
				else
					echo "your system is no supported my firewall script"
				fi;;
			"Install Puppet")
				SOURCE_SCRIPT $FunctionPath/puppet_install.sh
				PUPPET_VAR && SELECT_PUPPET_FUNCTION;;
			"create cron")
				SOURCE_SCRIPT $LibPath/decryption_encryption $FunctionPath/create_cron.sh
				SELECT_ENCRY_FUNCTION
				SELECT_CRON_FUNCTION;;
			"Exit")
				exit 0;;
			*)
				SELECT_RUN_SCRIPT;;
		esac
		break
	done
	SELECT_RUN_SCRIPT
}
SELECT_RUN_SCRIPT
