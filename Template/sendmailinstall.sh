#!/usr/bin/env bash
#! Encoding UTF-8
########################################################
# NOTE:
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2014
########################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
ScriptPath=$(cd $(dirname "$0") && pwd)
PyTools="@PyTools"
cn="false"
case $LANG in
	zh_CN*) cn="true";;
esac
#检测需要的程序
CmdTools="gzexe python"
HeadLines="60"
EXIT_LOG(){
	$cn && ExitLog="$1" || ExitLog="$2"
	echo "$(date +%Y-%m-%d-%H:%M) -ERR $ExitLog"|tee $ScriptPath/err.log && exit 1
}
for tmp in $CmdTools;do
	[[ -z $(which $tmp) ]] && EXIT_LOG "系统缺少运行本程序的命令，请先安装相应的命令:$tmp" "please install the corresponding command:$tmp"
done
PYTHON_TOOL_CREATE(){
	$cn && echo "正在生成程序文件,请稍等..." || echo "Program files is creating, please wait a moment..."
	PyToolsPath=$(tail -n +$HeadLines $0 | tar -zxf - |pwd) && echo $PyToolsPath
	cd $PyToolsPath && gzexe -d $PyTools &&	python -m py_compile $PyTools && mv $PyToolsPath/${PyTools}c $PyToolsPath/sendmail && PyTool=$PyToolsPath/sendmail && rm -rf $PyToolsPath/${PyTools}* || EXIT_LOG "程序生成失败!" "The corresponding create false!"
	if [ ! -f $PyToolsPath/sendmail.conf ] ;then
		$cn && echo "程序文件已生成,正在生成配置文件,请输入相关信息." || echo "Program is created , Now Generating configuration files, please input the relevant information."
		read -p "input mail's username :" MailUserName
		read -p "input mailuser's password :" MailUserPwd
		read -p "input mail server's smtp :" MailSmtp
		cat >$PyToolsPath/sendmail.conf<<eof
[email]
username = $MailUserName
passwd = 
smtp = $MailSmtp
eof
		python $PyTool -e $MailUserPwd
	else
		echo "================================"
		$cn && echo "程序文件已生成,配置文件路径为 $PyToolsPath/sendmail.conf." || echo "Program is created , And the configuration files is $PyToolsPath/sendmail.conf."
		echo "================================"
		$cn && echo "请根据实际情况先修改配置文件,密码是加密的,请用以下命令生成加密字串,程序会自动更新配置文件." || echo "Please according to the actual situation to modify the configuration file, the password is encrypted, please use the following command to generate encrypted string, the program will automatically update the configuration file."
		echo "================================"
		echo "python $PyTool -e '(Your Password)'"
		echo "================================"
	fi
	return 0
}
PYTHON_TOOL_CREATE
if [ $? = 0 ];then
	$cn && echo "程序文件已生成完毕,路径是\"$PyToolsPath/\",使用方法如下:" || echo "Program files generated, Path:\"$PyToolsPath/\", using method is as follows:"
	echo "================================"
	python $PyTool --version
	python $PyTool -h
fi
exit 0
