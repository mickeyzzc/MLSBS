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
SELECT_CRON_FUNCTION(){
	clear;
	echo "[Notice] Which cron_function you want to run:"
	select var in "ssh blacklist deny" "back";do
		case $var in
			"ssh blacklist deny")
				CRON_FOR_SSHDENY
				PASS_ENTER_TO_EXIT;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_SYSTEM_BASE_FUNCTION;;
		esac
		break
	done
}
