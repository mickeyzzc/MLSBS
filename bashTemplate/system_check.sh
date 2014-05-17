#!/bin/env bash
#########################################################################
# NOTE:
# The test system is Ubuntu14.04
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2014
#########################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
MyBashLogPath=
MailTool=
MsgAccessory=
[ ! -d $MyBashLogPath ] && mkdir -p $MyBashLogPath
BIG_FILE(){
	find $1 -type f -size +$2 -mtime $3 -mtime -$4 -exec stat -c "%s,%n" {} \;
}
HDD_CHECK(){
	BigPartition=$(df|awk '{print $5$6}'|awk -F'%' '{if($1>80 && $1<100)print $2}')
	for i in $BigPartition;do
		echo "It is not enough space on Partition $i" >> $MyBashLogPath/hdd$(date +"%Y%m%d").log
		BIG_FILE $i 20M 1 2 >> $MyBashLogPath/hdd$(date +"%Y%m%d").log
		BIG_FILE $i 200M 2 7 >> $MyBashLogPath/hdd$(date +"%Y%m%d").log
		BIG_FILE $i 500M 7 60 >> $MyBashLogPath/hdd$(date +"%Y%m%d").log
	done
	if [ -f $MyBashLogPath/hdd$(date +"%Y%m%d").log ];then
		MsgTitle="$(date -d "yesterday" +"%Y%m%d"), HDD Warning Mail"
		MsgHtml=$(cat $MyBashLogPath/hdd$(date +"%Y%m%d").log |sed 's/$/\<br\>/g')
		MY_MAIL $MsgTitle $MsgHtml
	else
		read -p "NO log to loading .... 10s to exit!" -t 10 ok
	fi
}
MY_MAIL(){
	MailReceiver=
	[[ "$3" == "" ]] && python $MailTool -s $1 -m $2 -t $MailReceiver || python $MailTool -s $1 -m $2 -f $3 -t $MailReceiver
}
case $1 in
'hdd')
	HDD_CHECK;;
*)
	HDD_CHECK;;
esac

