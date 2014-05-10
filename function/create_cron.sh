#!/bin/bash

[[ "$SysName" == 'centos' ]] && AuthLog="/var/log/secure" || AuthLog="/var/log/auth.log"
CronCmd=""
CronTime=""

AUTH_LOG_CHECK(){
	[ -f $AuthLog ] && cat $AuthLog|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{if($1>20)print $2;}'
}
CRON_CREATE(){
	grep "$1 $2" /etc/crontab > /dev/null
	[ $? -gt 0 ] && echo "$1 $2" >> /etc/crontab || echo "Nothing has be created"
}

