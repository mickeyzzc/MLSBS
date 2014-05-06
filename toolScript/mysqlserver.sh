#!/bin/env bash
#########################################################################
# NOTE:
# The test system is Ubuntu12.04
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2013
#########################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

username=
passwd=
mysqlhost=""
backuppath=

#MYSQL存活状态检测
mysqllive(){
    num=0
	while [[ `pidof mysqld` == "" ]] ; do
		echo "$(date +%Y%m%d%H%M),MYSQL IS DOWN" >> /var/log/mysqlstat.log
		service mysql start
		num=`expr $num + 1`
			if [ $num -gt 11 ] ; then
				echo "$(date +%Y%m%d%H%M),MYSQL NO UP" >> /var/log/mysqlstat.log
				exit 1
			fi
		sleep 10
	done
	#把生产线上的数据库赋值给数组变量
	mysqldata=`mysql -h$mysqlhost -u$username -p$passwd -e"show databases"|grep -vE "mysql|information_schema|performance_schema|Database"`
	if [ $num -gt 0 ] ; then
		mysqlsamchk
	fi
	
}
#MYSQL表检测和修复
mysqlsamchk(){
	mysqllive
	if [[ `which mysqlcheck` == "" ]] ;then
		for i in ${mysqldata[@]} ; do
			mytables=`mysql -h$mysqlhost -u$username -p$passwd -e"use $i;show tables;"|grep -vE "Tables_in_"`
			for j in ${mytables[@]} ; do
				table_status=`mysql -h$mysqlhost -u$username -p$passwd -e"check table $i.$j"|awk 'BEGIN{IFS='\t'}{print $3}'|grep "error"`
				if [[ ! "$table_status" == "" ]] ; then
					mysql -h$mysqlhost -u$username -p$passwd -e"repair table $i.$j"
					echo "$(date +%Y%m%d%H%M),$i.$j be repair" >> /var/log/mysqlstat.log
				fi
			done
		done
	else
		mysqlcheck --all-databases --auto-repair -u$username -p$passwd |awk '!/OK/ {printf "datetime,%s\n",$1}'|sed "s/datetime/$(date +%Y%m%d%H%M)/g" >> /var/log/mysqlstat.log
	fi
}
#备份数据库
mysqlbackup() {
mysqllive
[ ! -d $backuppath ] && mkdir $backuppath
for i in ${mysqldata[@]}
do
#先清理空间后在备份会比较稳当一点
	find $backuppath -name $i\_*.zip -type f -mtime +7 -exec rm {} \;
#备份后压缩保存
	mysqldump --opt -h$mysqlhost -u$username -p$passwd $i |gzip > $backuppath/$i\_$(date +%Y%m%d%H%M).zip
done
}
#FTP上传数据备份
dataftp() {
ftphost=$1
ftpusr=$2
ftpd=$3
ftpcmd='/usr/local/ectools/ectshell/myftp.py'
tmp="/tmp/$(date +%Y%m%d)"
[ ! -f $tmp ] && touch $tmp
cd $backuppath
for j in $(ls *$(date +%Y%m%d)* ); do
	md5sum $j >> $tmp
	python $ftpcmd -t upload -H $ftphost -u $ftpusr -p $ftpd -l $j -r "${j##*/}"
done

python $ftpcmd -t upload -H $ftphost -u $ftpusr -p $ftpd -l $tmp -r $(date +%Y%m%d)
rm $tmp
}
case $1 in
'check')
	mysqlsamchk ;;
'backup')
	mysqlbackup
	dataftp itecardtek.zapto.org ftpbackup ftp123;;
#	dataftp ectadmin.eicp.net ecadmin admin123 ;;
*)
	mysqllive ;;
esac
