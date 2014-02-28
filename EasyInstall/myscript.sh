#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;

ScriptPath=`pwd`
TEST_SCRIPT(){
if [ ! -f "$ScriptPath/function/$1" ]; then
	echo -e "not exist $ScriptPath/function/$1,so $0 can not be supported!"
	exit 1
else
	echo -e "loading function $1 now, continue ......"
	source $ScriptPath/function/$1
fi
}
#main
SELECT_RUN_SCRIPT(){
	clear;
	TEST_SCRIPT system_base_set.sh
	echo "[Notice] Which function you want to run:"
	select var in "Initialize System" "Install nginx with tomcat" "Install Mysql" "Install nginx and tomcat and mysql" "Install Puppet";do
		case $var in
			"Initialize System")
				SELECT_SYSTEM_BASE_FUNCTION;;
			"Install nginx with tomcat")
				TEST_SCRIPT nginx_tomcat_install.sh
				NGINX_VAR && SELECT_NGINX_TOMCAT_FUNCTION;;
			"Install Mysql")
				TEST_SCRIPT mysql_install.sh
				MYSQL_VAR && MYSQL_BASE_PACKAGES_INSTALL && INSTALL_MYSQL;;
			"Install nginx and tomcat and mysql")
				TEST_SCRIPT nginx_tomcat_install.sh
				TEST_SCRIPT mysql_install.sh
				NGINX_VAR && MYSQL_VAR && SELECT_NGINX_TOMCAT_FUNCTION && MYSQL_BASE_PACKAGES_INSTALL && INSTALL_MYSQL;;
			"Install Puppet")
				TEST_SCRIPT puppet_install.sh;;
			*)
				SELECT_RUN_SCRIPT;;
		esac
		break
	done
}
SELECT_RUN_SCRIPT