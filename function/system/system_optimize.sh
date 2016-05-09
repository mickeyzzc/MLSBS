#! Encoding UTF-8
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
#
#调用INSTALL_BASE_PACKAGES给系统安装一些必要的工具
#
SYSTEM_BASE_PACKAGES(){
	[ "$SysName" == 'centos' ] && BasePackages="wget crontabs logrotate openssl expect" || BasePackages="ntp logrotate wget cron curl openssl expect"
	INSTALL_BASE_PACKAGES $BasePackages
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
net.ipv4.ip_local_port_range = 10000 65000
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