#!/usr/bin/env bash
#! Encoding UTF-8
#########################################################################
# NOTE:
# The test system is Ubuntu12.04
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2013
#########################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

MysqlUser=
MysqlPwd=
MysqlHost=
MysqlBackupPath=/usr/local/mysqlbackup
MyBashLogPath=
[ ! -d $MyBashLogPath ] && mkdir -p $MyBashLogPath
#MYSQL存活状态检测
MYSQL_ALIVE(){
	Num=0
	while [[ `pidof mysqld` == "" ]] ; do
		echo "$(date +%Y%m%d%H%M),MYSQL IS DOWN" >> $MyBashLogPath/mysqlstat.log
		MysqlServer=$(ls /etc/init.d |grep mysql)
		/etc/init.d/$MysqlServer start
		Num=`expr $Num + 1`
			if [ $Num -gt 11 ] ; then
				echo "$(date +%Y%m%d%H%M),MYSQL NO UP" >> $MyBashLogPath/mysqlstat.log
				exit 1
			fi
		sleep 10
	done
	#把生产线上的数据库赋值给数组变量
	MysqlData=`mysql -h$MysqlHost -u$MysqlUser -p$MysqlPwd -e"show databases"|grep -vE "mysql|information_schema|performance_schema|Database"`
	if [ $Num -gt 0 ] ; then
		MYSQL_SAMCHK
	fi
}
#MYSQL表检测和修复
MYSQL_SAMCHK(){
	if [[ `which mysqlcheck` == "" ]] ;then
		for i in ${MysqlData[@]} ; do
			MyTables=`mysql -h$MysqlHost -u$MysqlUser -p$MysqlPwd -e"use $i;show tables;"|grep -vE "Tables_in_"`
			for j in ${MyTables[@]} ; do
				TableStatus=`mysql -h$MysqlHost -u$MysqlUser -p$MysqlPwd -e"check table $i.$j"|awk 'BEGIN{IFS='\t'}{print $3}'|grep "error"`
				if [[ ! "$TableStatus" == "" ]] ; then
					mysql -h$MysqlHost -u$MysqlUser -p$MysqlPwd -e"repair table $i.$j"
					echo "$(date +%Y%m%d%H%M),$i.$j be repair" >> $MyBashLogPath/mysqlstat.log
				fi
			done
		done
	else
		mysqlcheck --all-databases --auto-repair -u$MysqlUser -p$MysqlPwd |awk '!/OK/ {printf "datetime,%s\n",$1}'|sed "s/datetime/$(date +%Y%m%d%H%M)/g" >> $MyBashLogPath/mysqlstat.log
	fi
}
#备份数据库
MYSQL_BACKUP() {
	MYSQL_ALIVE
	[ ! -d $MysqlBackupPath ] && mkdir $MysqlBackupPath
	for i in ${MysqlData[@]};do
		#先清理空间后在备份会比较稳当一点
		find $MysqlBackupPath -type f -mtime +10 -exec rm {} \;
		#备份后压缩保存
		mysqldump --opt -h$MysqlHost -u$MysqlUser -p$MysqlPwd $i |gzip > $MysqlBackupPath/$i\_$(date +%Y%m%d%H%M).zip
	done
	cd $MysqlBackupPath
	for j in $(ls *$(date +%Y%m%d)* ); do
		md5sum $j >> $MysqlBackupPath/MD5$(date +%Y%m%d).txt
	done
}
case $1 in
'check')
	MYSQL_SAMCHK ;;
'backup')
	MYSQL_BACKUP;;
*)
	MYSQL_ALIVE ;;
esac
