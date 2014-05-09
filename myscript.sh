#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
#��ȡ�ű�·��
ScriptPath=$(cd $(dirname "$0") && pwd)
#������������
source $ScriptPath/config
#���ű��ļ��Ƿ���ڲ�����
SOURCE_SCRIPT(){
if [ ! -f "$1" ]; then
	echo -e "not exist $1,so $0 can not be supported!"
	exit 1
else
	echo -e "loading $1 now, continue ......"
	source $1
fi
}
#main
SELECT_RUN_SCRIPT(){
	clear;
	SOURCE_SCRIPT $FunctionPath/system_base_set.sh
	echo "[Notice] Which function you want to run:"
	select var in "Initialize System" "Install nginx" "Install tomcat" "Install Mysql" "Setup firewall" "Install Puppet" "Exit";do
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
					echo "wait my script update"
				elif [ ${SysVer%%.*} -eq 2 -o ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -le 12 ];then
					SOURCE_SCRIPT $FunctionPath/iptables_set.sh
					SELECT_IPTABLES_FUNCTION
				else
					echo "your system is no supported my firewall script"
				fi;;
			"Install Puppet")
				SOURCE_SCRIPT $FunctionPath/puppet_install.sh
				PUPPET_VAR && SELECT_PUPPET_FUNCTION;;
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