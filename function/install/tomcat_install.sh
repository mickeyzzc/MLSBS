#!/bin/env bash
TOMCAT_VAR(){
	ApacheLine="http://mirrors.cnnic.cn/apache"
	JdkVersion=""
	TomcatVersion=""
	TomcatPath="$InstallPath/tomcat"
	TomcatLine="$ApacheLine/tomcat"
}
TOMCAT_BASE_PACKAGES_INSTALL(){
	if [ "$SysName" == 'centos' ] ;then
		yum -y remove tomcat6 tomcat7;
		BasePackages="java-1.$JdkVersion.0 wget";
	else
		apt-get -y remove tomcat6 tomcat7;
		BasePackages="openjdk-$JdkVersion-jdk wget";
	fi
	INSTALL_BASE_PACKAGES $BasePackages
}
APR_INSTALL(){
	AprVersion="1"
	AprPor="apr apr-iconv apr-util"
	cd $DownloadTmp
	for var in $AprPor ;do
		wget -c -r -nd -np -L -A tar.gz $ApacheLine/apr/
	done
}
TOMCAT_INSTALL(){
	TOMCAT_BASE_PACKAGES_INSTALL
	cd $DownloadTmp
	rm -rf apache-tomcat-*
	wget -c -r -nd -np -L -A tar.gz -R deployer.tar.gz,fulldocs.tar.gz,src.tar.gz,embed.tar.gz $TomcatLine/tomcat-$TomcatVersion/
	TomcatPackage=`ls apache-tomcat-$TomcatVersion*`
	tar zxf $TomcatPackage
	[ ! -d $TomcatPath ] && mkdir $TomcatPath
	cp -R $DownloadTmp/${TomcatPackage%".tar.gz"}/* $TomcatPath
	[ -f $TomcatPath/bin/catalina.sh ] && JAVARAM=`expr $RamTotal / 2` &&	sed -i "2 a JAVA_OPTS=\"-server -Xms${JAVARAM}m -Xmx${JAVARAM}m -XX:+AggressiveOpts  -XX:+UseBiasedLocking -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+UseParNewGC\"" $TomcatPath/bin/catalina.sh
	$TomcatPath/bin/startup.sh
}
SELECT_TOMCAT_FUNCTION(){
	clear;
	echo "[Notice] Which tomcat's version you want to install:"
	select var in "tomcat6" "tomcat7" "tomcat8" "back";do
		case $var in
			"tomcat6")
				TomcatVersion="6" && JdkVersion="6";;
			"tomcat7")
				TomcatVersion="7" && JdkVersion="7";;
			"tomcat8")
				TomcatVersion="8" && JdkVersion="7";;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_TOMCAT_FUNCTION;;
		esac
		break
	done
	[ -n $TomcatVersion -a -n $JdkVersion ] && TOMCAT_INSTALL
	APR_INSTALL
}
