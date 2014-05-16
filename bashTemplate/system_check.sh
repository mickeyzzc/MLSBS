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
MyBashLogPath="/var/log/mybash"
MailTool=""
MsgDate=$(date -d "yesterday" +"%Y%m%d")
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
}
MY_MAIL(){
	MailReceiver=""
	MsgTitle=$1
	MsgHtml=$2
	MsgAccessory=$3
	[[ "$MsgAccessory" == "" ]] && python $MailTool -s $MsgTitle -m $MsgHtml -t $MailReceiver
	
}


