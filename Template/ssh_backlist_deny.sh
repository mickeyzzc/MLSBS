#!/usr/bin/env bash
#! Encoding UTF-8
#########################################################################
# NOTE:
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2013
#########################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
MyBashLogPath=@MyBashLogPath
[ ! -d $MyBashLogPath ] && mkdir -p $MyBashLogPath
find $MyBashLogPath -name sshbacklist* -type f -mtime +30 -exec rm {} \;
cat @AuthLog |awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{if($1>10)print $1","$2;}' > $MyBashLogPath/sshbacklist$(date +"%Y%m%d").log
for Ip in $(cat $MyBashLogPath/sshbacklist$(date +"%Y%m%d").log|awk -F "," '{print $2}');do
	grep $Ip /etc/hosts.deny > /dev/null
	[ $? -gt 0 ] && echo "sshd:$Ip" >> /etc/hosts.deny
done
