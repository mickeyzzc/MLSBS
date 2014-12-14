#! Encoding UTF-8
CRON_VARS(){
	CronCmd=""
	CronUser=""
	CronTime=""
	MyBashLogPathTmp=$(echo $MyBashLogPath|sed 's/\//\\\//g')
}
[ ! -d $MyCronBashPath ] && mkdir -p $MyCronBashPath
CRON_CREATE(){
	grep "$CronCmd" /etc/crontab > /dev/null
	if [ $? -gt 0 ];then
		echo -e "$1" >> /etc/crontab
		INFO_MSG "任务 ：\"$1 \"已生成." "CRON :\"$1 \" is created."
		return 0
	else
		INFO_MSG "任务没有生成。" "Nothing has be created"
		return 1
	fi
}
CRON_FOR_SSHDENY(){
	[[ "$SysName" == 'centos' ]] && AuthLog="/var/log/secure" || AuthLog="/var/log/auth.log"
	TEST_FILE $TemplatePath/ssh_backlist_deny.sh
	BACK_TO_INDEX
	TEST_FILE $AuthLog
	BACK_TO_INDEX
	AuthLogTmp=$(echo $AuthLog|sed 's/\//\\\//g')
	cat $TemplatePath/ssh_backlist_deny.sh|sed -e "s/@AuthLog/$AuthLogTmp/g" -e "s/@MyBashLogPath/$MyBashLogPathTmp/g" > $MyCronBashPath/ssh_backlist_deny.sh
	[[ -n "$ENCRY_FUNCTION" ]] && $ENCRY_FUNCTION $MyCronBashPath/ssh_backlist_deny.sh
	CronUser="root"
	CronTime='00 5    * * *'
	CronCmd="bash $MyCronBashPath/ssh_backlist_deny.sh"
	CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
}
CRON_FOR_SYSTEM_CHECK(){
	TEST_FILE $TemplatePath/system_check.sh
	BACK_TO_INDEX
	TEST_FILE $Python2Path/sendmail.py
	BACK_TO_INDEX
	TEST_FILE $Python2Path/pyconfig.conf
	BACK_TO_INDEX
	cp $Python2Path/sendmail.py $Python2Path/pyconfig.conf $MyCronBashPath/
	chown 700 $MyCronBashPath/sendmail.py
	read -p "Input mail address :" MsgAccessory
	cat $TemplatePath/system_check.sh |sed -e "s/MyBashLogPath=/MyBashLogPath=$MyBashLogPathTmp/g" -e "s/MailTool=/MailTool=$(echo $MyCronBashPath/sendmail.py|sed 's/\//\\\//g')/g" -e "s/MsgAccessory=/MsgAccessory=$MsgAccessory/g" > $MyCronBashPath/system_check.sh
	[[ -n "$ENCRY_FUNCTION" ]] && $ENCRY_FUNCTION $MyCronBashPath/system_check.sh
	CronUser="root"
	CronTime='10 1    * * *'
	CronCmd="bash $MyCronBashPath/system_check.sh hdd"
	CRON_CREATE "$CronTime\t$CronUser\t$CronCmd"
}
SELECT_CRON_FUNCTION(){
	CRON_VARS
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择需要生成的任务:"
		VarLists=("返回首页" "SSH黑名单生成任务" "系统日常自检任务")
	else
		echo "[Notice] Which cron_function you want to run:"
		VarLists=("back" "ssh_blacklist_deny" "check_system")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				CRON_FOR_SSHDENY;;
			${VarLists[2]})
				CRON_FOR_SYSTEM_CHECK;;
			${VarLists[0]})
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_CRON_FUNCTION;;
		esac
		PASS_ENTER_TO_EXIT
		break
	done
}
