#! Encoding UTF-8
TOOLS_LISTS(){
	if $cn ;then
		ToolsNameLists=("邮件小工具")
	else
		ToolsNameLists=("Send_MAIL_Tool")
	fi
	ToolsScript=("${ScriptPath}/Template/py2/sendmail.py")
	InstallScript=("${ScriptPath}/Template/sendmailinstall.sh")
}
SELECT_TOOLS_CREATE(){
	echo "----------------------------------------------------------------"
	declare -a VarLists
	declare TmpMsg
	declare count
	TOOLS_LISTS
	if $cn ;then
		echo "[Notice] 请选择需要生成的任务:"
		TmpMsg="返回首页"
	else
		echo "[Notice] Which cron_function you want to run:"
		TmpMsg="back"
	fi
	VarLists=(${ToolsNameLists[@]})
	select var in "$TmpMsg" ${VarLists[@]} ;do
		case $var in
			$TmpMsg)
				SELECT_RUN_SCRIPT;;
			*)
				count=0
				for i in ${VarLists[@]};do
					if [[ "$i" == "$var" ]];then
						PACKET_TOOLS "${ToolsScript[$count]}" "${InstallScript[$count]}"
						break
					fi
					count=$(expr $count + 1)
				done
				SELECT_TOOLS_CREATE;;
		esac
		PASS_ENTER_TO_EXIT
		break
	done
}
