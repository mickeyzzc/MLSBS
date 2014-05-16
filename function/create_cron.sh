#!/bin/bash

[[ "$SysName" == 'centos' ]] && AuthLog="/var/log/secure" || AuthLog="/var/log/auth.log"
CronCmd=""
CronUser=""
CronTime=""
MyBashLogPathTmp=$(echo $MyBashLogPath|sed 's/\//\\\//g')
[ ! -d $MyCronBashPath ] && mkdir -p $MyCronBashPath
CRON_CREATE(){
	grep "$CronCmd" /etc/crontab > /dev/null
	[ $? -gt 0 ] && echo -e "$1" >> /etc/crontab || echo "Nothing has be created"
}
CRON_FOR_SSHDENY(){
	TEST_FILE $BashTemplatePath/ssh_backlist_deny.sh
	TEST_FILE $AuthLog
	AuthLogTmp=$(echo $AuthLog|sed 's/\//\\\//g')
	cat $BashTemplatePath/ssh_backlist_deny.sh|sed -e "s/var\[1\]/$AuthLogTmp/g" -e "s/MyBashLogPath=/MyBashLogPath=$MyBashLogPathTmp/g" > $MyCronBashPath/ssh_backlist_deny.sh
	CronUser="root"
	CronTime='00 5    * * *'
	CronCmd="bash $MyCronBashPath/ssh_backlist_deny.sh"
	CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
}
CRON_FOR_MYSQL_SERVER(){
	if [ e`which mysqldump` == "e" -o a`which mysql` == "a" ];then
		read -p "Your system is not supported this task" -t 5 ok
	else
		TEST_FILE $BashTemplatePath/mysql_server.sh
		while true ; do
			read -p "Please input mysql server's ip:" MysqlHost
			read -p "Please input mysql server's username:" MysqlUser
			read -p "Please input mysql server's password:" MysqlPwd
			#read -p "Whice is the backup directory :" MysqlBackupPath
			mysql -h$MysqlHost -u$MysqlUser -p$MysqlPwd -e"show databases" 2>&1 >>/dev/null
			[ $? -gt 0 ] && echo "input err, please input again!" || break
		done
		cat $BashTemplatePath/mysql_server.sh |sed -e "s/MysqlUser=/MysqlUser=$MysqlUser/g" -e "s/MysqlPwd=/MysqlPwd=$MysqlPwd/g" -e "s/MysqlHost=/MysqlHost=$MysqlHost/g" -e "s/MyBashLogPath=/MyBashLogPath=$MyBashLogPathTmp/g" > $MyCronBashPath/mysql_server.sh
		chown 700 $MyCronBashPath/mysql_server.sh
		CronUser="root"
		CronTime='10 0    * * *'
		CronCmd="bash $MyCronBashPath/mysql_server.sh backup"
		CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
	fi
}
CRON_FOR_SYSTEM_CHECK(){
	TEST_FILE $BashTemplatePath/system_check.sh
	TEST_FILE $Python2Path/sendmail.py
	TEST_FILE $Python2Path/pyconfig.conf
	cp $Python2Path/sendmail.py $Python2Path/pyconfig.conf $MyCronBashPath/
	chown 700 $MyCronBashPath/sendmail.py
	cat $BashTemplatePath/system_check.sh |sed -e "s/MyBashLogPath=/MyBashLogPath=$MyBashLogPathTmp/g" -e "s/MailTool=/MailTool=$(echo $MyCronBashPath/sendmail.py|sed 's/\//\\\//g')/g" > $MyCronBashPath/system_check.sh
	CronUser="root"
	CronTime='10 1    * * *'
	CronCmd="bash $MyCronBashPath/system_check.sh hdd"
	CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
}
SELECT_CRON_FUNCTION(){
	clear;
	echo "[Notice] Which cron_function you want to run:"
	select var in "ssh blacklist deny" "backup mysql's datebases" "check system" "back";do
		case $var in
			"ssh blacklist deny")
				CRON_FOR_SSHDENY;;
			"backup mysql's datebases")
				CRON_FOR_MYSQL_SERVER;;
			"check system")
				CRON_FOR_SYSTEM_CHECK;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_SYSTEM_BASE_FUNCTION;;
		esac
		PASS_ENTER_TO_EXIT
		break
	done
}
