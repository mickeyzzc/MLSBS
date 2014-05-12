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
backuplog=/var/log/mysql_dump$(date +%Y%m).log
[ ! -f $backuplog ] && touch $backuplog
num=0
while [ ! -f $backuppath/$(date +%Y%m%d) ] ; do
    num=`expr $num + 1`
	sleep 10m
	if [ $num -gt 12 ] ; then
		exit 1
	fi
done
[[ `ls $backuppath/*$(date +%Y%m%d)*.zip |wc -l` == `cat $backuppath/$(date +%Y%m%d)|wc -l` ]] || exit 1 &&
cd $backuppath
for i in $(ls *$(date +%Y%m%d)* ); do	
	tmp=`md5sum $i`
	if [[ `grep "$tmp" $backuppath/$(date +%Y%m%d)` == "" ]] ;then
		echo "$(date +%Y%m%d%H%M),$i is damage" >> $backuplog
	else
		mysql -h$mysqlhost -u$username -p$passwd -e"CREATE DATABASE IF NOT EXISTS ${i%%_2*} CHARACTER SET utf8"
		zcat $i | mysql -h$mysqlhost -u$username -p$passwd ${i%%_2*}
		echo "$(date +%Y%m%d%H%M),$i is dump" >> $backuplog
	fi
done
#rm $backuppath/$(date +%Y%m%d)