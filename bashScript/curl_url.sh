#!/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH
clear
Url="http://mirrors.cnnic.cn/apache/activemq/apache-activemq/"
DownListFile="/tmp/downlist.txt"
DownListTmpFile="/tmp/tmplist.txt"
UrlBack="$Url"
[ ! -f $DownListFile ] && touch $DownListFile || echo > $DownListFile
[ ! -f $DownListTmpFile ] && touch $DownListTmpFile || echo > $DownListTmpFile
CURL_URLS(){
	Urls=`curl $UrlBack |awk -F "a href=\"" '{printf "%s\n",$2}'|awk -F "\"" '{printf "%s\n",$1}'|grep -vE "^$|^\?|^http:\/\/|\\\n#"`
}
URL_LIST(){
	CURL_URLS
	for i in $Urls ;do
		echo "$UrlBack$i\n" >> $DownListTmpFile
	done
}
RECURSIVE_SEARCH_URL(){
UrlBackTmps=`cat $DownListTmpFile`
for j in $UrlBackTmps ;do
	[[ "$j" == "" ]] && echo "no more page for search" && exit 1
	if [[ "${j##*\/}" != "" ]] ;then
		echo "$j" >> $DownListFile
	else
		UrlBack="$j"
		URL_LIST
	fi
	UrlTmps=`grep -vE "$j$" $DownListTmpFile`
	echo "$UrlTmps" > $DownListTmpFile
	RECURSIVE_SEARCH_URL
done
}
URL_LIST $Urls
RECURSIVE_SEARCH_URL