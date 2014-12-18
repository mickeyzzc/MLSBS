#!/usr/bin/env bash
#! Encoding UTF-8
#add system's administrator
#
#新增一名具备sudo权限的管理员，
#
NEWUSER_ADD(){
	declare NewUser
	declare UserPwd
	declare TmpMsg
	declare TmpChooge
	$cn && TmpMsg="请问是否添加管理员帐号(y/n):" || TmpMsg="Whether to add administrator account(y/n):"
	while true; do
		read -p "$TmpMsg" TmpChooge
		if [ "$TmpChooge" != "y" -o "$TmpChooge" != "Y" -o "$TmpChooge" != "n" -o "$TmpChooge" != "N" ];then
			break
		else
			INFO_MSG "请输入(Y,y,N,n)中的任意字母选择." "Please enter (Y, y, N, n) select any of the letters"
		fi
	done
	$cn && TmpMsg="请输入要添加的用户帐号:" || TmpMsg="Please input User's name:"
	while [[ -z "$NewUser" ]]; do
		read -p "$TmpMsg" NewUser
		if [[ -n $(grep "${NewUser}:" /etc/passwd) ]];then
			INFO_MSG "用户已存在,请重新输入." "User already exists, please re-entry ."
			NewUser=""
		fi
	done
	$cn && TmpMsg="请输入用户密码:" || TmpMsg="Please input User's password:"
	while [[ -z "$UserPwd" ]] ;do
		read -s -p "$TmpMsg" UserPwd
		if [[ -z "$UserPwd" ]];then
			INFO_MSG "密码不能为空,请重新输入." "Password cannot be empty, please re-entry ."
			UserPwd=""
		fi
	done
	INFO_MSG "正在添加用户,请稍后." "Is add user, please later."
	[ "$TmpChooge" != "y" -o "$TmpChooge" != "Y" ] && useradd -G sudo -d /home/$NewUser -m -N -s /bin/bash $NewUser || useradd -d /home/$NewUser -m -s /bin/bash $NewUser
	echo $NewUser:"$UserPwd" |chpasswd
	INFO_MSG "用户\"${NewUser}\"已添加." "The user \"${NewUser}\" has to add"
}
#system timezone set
#
#调正时钟
#
TIMEZONE_SET(){
	rm -rf /etc/localtime;
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	INFO_MSG '[正在安装 ntp] ******************************** >>' '[ntp Installing] ******************************** >>'
	[ "$SysName" == 'centos' ] && yum install -y ntp 1>/dev/null || apt-get install -y ntpdate 1>/dev/null
	INFO_MSG "安装完成,正在设置时间更新任务......" "Install is over, now setup the update crontab ....... "
	ntpdate -u pool.ntp.org
	TimeCron="0 * * * *	root /usr/sbin/ntpdate cn.pool.ntp.org >>/dev/null 2>&1 ;hwclock -w"
	[[ -z $(grep "$TimeCron" /etc/crontab) ]] && echo "$TimeCron" >> /etc/crontab
	[ "$SysName" == 'centos' ] && /etc/init.d/crond restart || /etc/init.d/cron restart
	INFO_MSG "时区设置完成,系统时区为上海时区." "Timezone is Shanghai , Now setup over ."
}
#main
SELECT_SYSTEM_SETUP_FUNCTION(){
	clear;
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择要运行的指令:"
		VarLists=("返回首页" "添加用户" "一键优化" "时区设置" "设置防火墙")
	else
		echo "[Notice] Which function you want to run:"
		VarLists=("back" "Add_User" "One_key_to_Optimize" "Timezone_set" "Iptables_set")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				NEWUSER_ADD;;
			${VarLists[2]})
				SOURCE_SCRIPT $FunctionPath/system/system_optimize.sh;;
			${VarLists[3]})
				TIMEZONE_SET;;
			${VarLists[4]})
				SOURCE_SCRIPT $FunctionPath/system/iptables_setup.sh
				if [ ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -ge 13 ];then
					read -p "wait my script update" -t 5 ok
				elif [ ${SysVer%%.*} -eq 2 -o ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -le 25 ];then
					SOURCE_SCRIPT $FunctionPath/system/iptables_setup.sh
					SELECT_IPTABLES_FUNCTION
				else
					echo "your system is no supported my firewall script"
				fi;;
			${VarLists[0]})
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_SYSTEM_SETUP_FUNCTION;;
		esac
		break
	done
}
