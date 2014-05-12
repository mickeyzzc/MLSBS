#!/bin/bash

[[ "$SysName" == 'centos' ]] && AuthLog="/var/log/secure" || AuthLog="/var/log/auth.log"
CronCmd=""
CronUser=""
CronTime=""
[ ! -d $MyCronBashPath ] && mkdir -p $MyCronBashPath
CRON_CREATE(){
	grep "$1 $2 $3" /etc/crontab > /dev/null
	[ $? -gt 0 ] && echo "$1 $2 $3" >> /etc/crontab || echo "Nothing has be created"
}
CRON_FOR_SSHDENY(){
	TEST_FILE $BashTemplatePath/ssh_backlist_deny.sh
	TEST_FILE $AuthLog
	cp $BashTemplatePath/ssh_backlist_deny.sh $MyCronBashPath/ssh_backlist_deny.sh
	sed -i 's/var[1]/$AuthLog/g' $MyCronBashPath/ssh_backlist_deny.sh
	CronTime="00 5    * * *"
	CronUser="root"
	CronCmd="bash $MyCronBashPath/ssh_backlist_deny.sh"
	CRON_CREATE $CronTime $CronUser $CronCmd
}
