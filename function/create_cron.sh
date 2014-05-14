#!/bin/bash

[[ "$SysName" == 'centos' ]] && AuthLog="/var/log/secure" || AuthLog="/var/log/auth.log"
CronCmd=""
CronUser=""
CronTime=""
[ ! -d $MyCronBashPath ] && mkdir -p $MyCronBashPath
CRON_CREATE(){
	grep "$CronCmd" /etc/crontab > /dev/null
	[ $? -gt 0 ] && echo -e "$1" >> /etc/crontab || echo "Nothing has be created"
}
CRON_FOR_SSHDENY(){
	TEST_FILE $BashTemplatePath/ssh_backlist_deny.sh
	TEST_FILE $AuthLog
	AuthLogTmp=$(echo $AuthLog|sed 's/\//\\\//g')
	cat $BashTemplatePath/ssh_backlist_deny.sh|sed "s/var\[1\]/$AuthLogTmp/g" > $MyCronBashPath/ssh_backlist_deny.sh
	CronUser="root"
	CronTime='00 5    * * *'
	CronCmd="bash $MyCronBashPath/ssh_backlist_deny.sh"
	CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
}
CRON_FOR_MYSQL_SERVER(){
	if [ a`which mysqldump`=="a" -o e`which mysql`=="e" ];then
		read -p "Your system is not supported this task" -t 30 ok
	else
		TEST_FILE $BashTemplatePath/mysql_server.sh
		while true ; do
			read -p "Please input mysql server's ip:" MysqlHost
			read -p "Please input mysql server's username:" MysqlUser
			read -p "Please input mysql server's password:" MysqlPwd
			#read -p "Whice is the backup directory :" MysqlBackupPath
			mysql -h$MysqlHost -u$MysqlUser -p$MysqlPwd -e"show databases" 2>&1 >>/dev/null
			[ $? -gt 0 ] && break || echo "input err, please input again!"
		done
		cat $BashTemplatePath/mysql_server.sh |sed -e "s/MysqlUser=/MysqlUser=$MysqlUser/g" -e "s/MysqlPwd=/MysqlPwd=$MysqlPwd/g" -e "s/MysqlHost=/MysqlHost=$MysqlHost/g" > $MyCronBashPath/mysql_server.sh
		chown 700 $MyCronBashPath/mysql_server.sh
		CronUser="root"
		CronTime='10 0    * * *'
		CronCmd="bash $MyCronBashPath/mysql_server.sh backup"
		CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
	fi
}
SELECT_CRON_FUNCTION(){
	clear;
	echo "[Notice] Which cron_function you want to run:"
	select var in "ssh blacklist deny" "backup mysql's datebases" "back";do
		case $var in
			"ssh blacklist deny")
				CRON_FOR_SSHDENY;;
			"backup mysql's datebases")
				CRON_FOR_MYSQL_SERVER;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_SYSTEM_BASE_FUNCTION;;
		esac
		PASS_ENTER_TO_EXIT
		break
	done
}
