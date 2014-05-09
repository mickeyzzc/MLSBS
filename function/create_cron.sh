#!/bin/bash

[[ "$SysName" == 'centos' ]] && AuthLog="/var/log/secure" || AuthLog="/var/log/auth.log"
CronCmd
CmdTemplatePath
AUTH_LOG_CHECK(){
	[ -f $AuthLog ] && cat $AuthLog|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{if($1>20)print $2;}'
}
