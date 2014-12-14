#!/usr/bin/env bash
#! Encoding UTF-8
#add system's administrator
#
#新增一名具备sudo权限的管理员，
#
ADMINUSER_ADD(){
	AdminUser=""
	AdminPwd=""
	[ -z $AdminUser ] && read -p "Please input AdminUser's name:" AdminUser
	[ -z $AdminPwd ] && read -p "Please input AdminUser's password:" AdminPwd
	useradd -G sudo -d /home/$AdminUser -m -N -s /bin/bash $AdminUser
	echo $AdminUser:"$AdminPwd" |chpasswd
}
#system timezone set
#
#调正时钟
#
TIMEZONE_SET(){
	rm -rf /etc/localtime;
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;
	echo '[ntp Installing] ******************************** >>';
	[ "$SysName" == 'centos' ] && yum install -y ntp || apt-get install -y ntpdate;
	ntpdate -u pool.ntp.org;
	TimeCron="0 * * * * root /usr/sbin/ntpdate cn.pool.ntp.org >>/dev/null 2>&1 ;hwclock -w"
	[[ -z $(grep "$TimeCron" /etc/crontab) ]] && echo "$TimeCron" >> /etc/crontab
	[ "$SysName" == 'centos' ] && /etc/init.d/crond restart || /etc/init.d/cron restart
}
#main
SELECT_SYSTEM_SETUP_FUNCTION(){
	clear;
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择要运行的指令:"
		VarLists=("返回首页" "增加管理员" "一键优化" "时区设置" "设置防火墙")
	else
		echo "[Notice] Which function you want to run:"
		VarLists=("back" "Admin_add" "One_key_to_Optimize" "Timezone_set" "Iptables_set")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				ADMINUSER_ADD;;
			${VarLists[2]})
				SOURCE_SCRIPT $FunctionPath/system/system_optimize.sh;;
			${VarLists[3]})
				TIMEZONE_SET;;
			${VarLists[4]})
				SOURCE_SCRIPT $FunctionPath/system/iptables_setup.sh
				if [ ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -ge 13 ];then
					read -p "wait my script update" -t 5 ok
				elif [ ${SysVer%%.*} -eq 2 -o ${SysVer%%.*} -eq 3 -a ${SysVer##*.} -le 25 ];then
					SOURCE_SCRIPT $FunctionPath/iptables_set.sh
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
