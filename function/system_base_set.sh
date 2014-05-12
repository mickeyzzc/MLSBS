#!/bin/bash
PASS_ENTER_TO_EXIT(){
	read -p "input enter to exit" -t 60 ok
}
TEST_FILE(){
	if [ ! -f $1 ];then
		echo "Not exist $1"
		PASS_ENTER_TO_EXIT
		SELECT_RUN_SCRIPT
	else
		echo "loading $1 now..."
	fi
}
#add system's administrator
#
#新增一名具备sudo权限的管理员，
#
ADMINUSER_ADD(){
	AdminUser=""
	AdminPwd=""
	[[ "$AdminUser" == '' ]] && read -p "Please input AdminUser's name:" AdminUser
	[[ "$AdminPwd" == '' ]] && read -p "Please input AdminUser's password:" AdminPwd
	useradd -G sudo -d /home/$AdminUser -m -N -s /bin/bash $AdminUser
	echo $AdminUser:"$AdminPwd" |chpasswd
}
#
#把其他不必要的用户屏蔽登陆
#
OTHER_USER_NOLONGIN(){
	for UserID in `grep -vE "root|sys" /etc/passwd|cut -d : -f 3`; do
		UserName=`awk -F ':' -v UserID="$UserID" '{if (UserID == $3) print $1}' /etc/passwd`
		if [ "$SysName" == 'centos' -a "$UserID" -lt 500 ] || [ "$SysName" != 'centos' -a "$UserID" -lt 1000 ];then
			passwd -l $UserName
			usermod -s /sbin/nologin $UserName
			echo -e "$UserName is disenable login"
		fi
	done
}
#install some tool
#
#这功能可以给其他脚本调用来安装基础软件，如编译mysql需要的gcc等工具
#
INSTALL_BASE_PACKAGES(){
	if [ "$SysName" == 'centos' ]; then
		echo '[yum-fastestmirror Installing] ************************************************** >>';
		[[ "$SysCount" == '' ]] && yum -y install yum-fastestmirror && SysCount="1"
		cp /etc/yum.conf /etc/yum.conf.back
		sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
		for arg do
			echo "[${arg} Installing] ************************************************** >>";
			yum -y install $arg; 
		done;
		mv -f /etc/yum.conf.back /etc/yum.conf;
	else
		[[ "$SysCount" == '' ]] && apt-get update && SysCount="1"
		for arg do
			echo "[${arg} Installing] ************************************************** >>";
			apt-get install -y $arg --force-yes;apt-get -fy install;apt-get -y autoremove; 
		done;
	fi;
}
#
#调用INSTALL_BASE_PACKAGES给系统安装一些必要的工具
#
SYSTEM_BASE_PACKAGES(){
	[ "$SysName" == 'centos' ] && BasePackages="wget crontabs logrotate openssl expect" || BasePackages="ntp logrotate wget cron curl openssl expect"
	INSTALL_BASE_PACKAGES $BasePackages
}
#system timezone set
#
#调正时钟
#
TIMEZONE_SET(){
	rm -rf /etc/localtime;
	ln -s /usr/share/zoneinfo/Asia/Chongqing /etc/localtime;
	echo '[ntp Installing] ******************************** >>';
	[ "$SysName" == 'centos' ] && yum install -y ntp || apt-get install -y ntpdate;
	ntpdate -u pool.ntp.org;
	TimeCron="0 * * * * /usr/sbin/ntpdate cn.pool.ntp.org >> /dev/null 2>&1 ;hwclock -w"
	[[ "$(grep $TimeCron /etc/crontab)" == "" ]] && echo "$TimeCron" >> /etc/crontab
	[ "$SysName" == 'centos' ] && /etc/init.d/crond restart || /etc/init.d/cron restart
}
#
#系统的基本设置，可根据自己的需要添加
#
BASE_OS_SET(){
# EOF **********************************
	cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 1
#net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65000
EOF
# **************************************
	sysctl -p
# EOF **********************************
	cat >> /etc/security/limits.conf << EOF
*                     soft     nofile             `expr $FileMax / 4`
*                     hard     nofile             `expr $FileMax / 2`
EOF
# **************************************
}
#main
SELECT_SYSTEM_BASE_FUNCTION(){
	clear;
	echo "[Notice] Which system_base_function you want to run:"
	select var in "Admin user add" "Prohibit the default user" "System base packages install" "Timezone set" "System core set" "back";do
		case $var in
			"Admin user add")
				ADMINUSER_ADD;;
			"Prohibit the default user")
				OTHER_USER_NOLONGIN;;
			"System base packages install")
				SYSTEM_BASE_PACKAGES;;
			"Timezone set")
				TIMEZONE_SET;;
			"System core set")
				BASE_OS_SET;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_SYSTEM_BASE_FUNCTION;;
		esac
		break
	done
}
