#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
#获取脚本路劲
ScriptPath=$(cd $(dirname "$0") && pwd)
#加载配置内容
#source $ScriptPath/config
#check system parameter about cpu's core ,ram ,other
#
#收集系统的一些基础参数给其他函数使用
#
SysName=""
[[ $(id -u) != '0' ]] && echo '[Error] Please use root to run this script.' && exit 1;
for tmp in "centos" "debian" "ubuntu" ; do
	egrep -i $tmp /etc/issue && SysName=$tmp && SysVer=$(egrep -i $tmp /etc/issue|cut -d. -f1|awk '{print $NF}')
	#SysVer=`uname -r|cut -d. -f1-2`
done

[[ "$SysName" == '' ]] && echo '[Error] Your system is not supported this script' && exit;
# SysBit='32' && [ `getconf WORD_BIT` == '32' ] && [ `getconf LONG_BIT` == '64' ] && SysBit='64';
# CpuNum=`cat /proc/cpuinfo |grep 'processor'|wc -l`;
# RamTotal=`free -m | grep 'Mem' | awk '{print $2}'`;
# RamSwap=`free -m | grep 'Swap' | awk '{print $2}'`;
# RamSum=$[$RamTotal+$RamSwap];
# FileMax=`cat /proc/sys/fs/file-max`
# OSlimit=`ulimit -n`

INSTALL_BASE_PACKAGES(){
	if [ "$SysName" == "centos" -a "$SysVer" == "6" ]; then
		echo '[yum-fastestmirror Installing] ************************************************** >>';
		yum -y install yum-fastestmirror
		cp /etc/yum.conf /etc/yum.conf.back
		sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
		yum -y upgrade
		yum -y install wget ntpdate &&
		wget -P /etc/yum.repos.d/ http://ftp.openvz.org/openvz.repo &&
		rpm --import http://ftp.openvz.org/RPM-GPG-Key-OpenVZ &&
		yum -y install vzkernel
		[ "$SysName" == "centos" -a "$SysVer" == "6" ] && echo "SELINUX=disabled" > /etc/sysconfig/selinux
		yum -y install vzctl vzquota ploop
		mv -f /etc/yum.conf.back /etc/yum.conf;
	else
		apt-get update
		apt-get -y autoremove --purge;
		dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P 
	fi;
}
CONFIG_SET(){
	cp /etc/sysctl.conf /etc/sysctl.conf$(date +%Y%m%d%H%M)
cat >/etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.all.rp_filter = 1
kernel.sysrq = 1
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.all.send_redirects = 0
EOF
}
INSTALL_BASE_PACKAGES && CONFIG_SET