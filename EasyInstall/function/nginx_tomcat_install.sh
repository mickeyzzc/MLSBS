#!/bin/bash

NGINX_VAR(){
	SysName=
	TomcatVersion=""
	NginxVersion="nginx-1.4.5"
	NginxPath="/usr/local/nginx"
	ServerIP="127.0.0.1"
	ServerHostName=""
	[[ "$ServerHostName" == '' ]] && echo "Please input domain name:";read ServerHostName
}
NGINX_BASE_PACKAGES_INSTALL(){
	if [ "$SysName" == 'centos' ] ;then
		yum -y remove httpd;
		BasePackages="gcc gcc-c++ openssl-devel pcre pcre-devel zlib-devel zlib make openssl $TomcatVersion";
	else
		apt-get -y remove nginx apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker;
		BasePackages="gcc g++ make libpcre3 libpcre3-dev libssl-dev zlibc openssl zlib1g zlib1g-dev $TomcatVersion";
	fi
	INSTALL_BASE_PACKAGES $BasePackages
}
NGINX_INSTALL(){
	NGINX_BASE_PACKAGES_INSTALL
	cd /tmp/
	[ ! -f $NginxVersion.tar.gz ] && curl -O http://nginx.org/download/$NginxVersion.tar.gz
	tar zxf $NginxVersion.tar.gz
	cd /tmp/$NginxVersion
	./configure  --prefix=$NginxPath --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --conf-path=$NginxPath/conf/nginx.conf --with-mail --with-mail_ssl_module
	make && make install
}
NGINX_CONF_SET(){
	[[ "$TomcatVersion" != "" ]] && JAVARAM=`expr $RamTotal / 2` &&	sed -i "/\/bin\//a JAVA_OPTS=\"-server -Xms${JAVARAM}m -Xmx${JAVARAM}m\"" /usr/share/$TomcatVersion/bin/catalina.sh
	[ -f $NginxPath/conf/nginx.conf ] && cp $NginxPath/conf/nginx.conf $NginxPath/conf/nginx.conf.backup$(date +%Y%m%d%H%M)
cat >$NginxPath/conf/nginx.conf <<EOF
user www-data;
worker_processes $CpuNum;
events {
    worker_connections  `expr $CpuNum \* 2048`;
}
http {
    include mime.types;
    default_type  application/octet-stream;
	log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
	sendfile on;
	tcp_nopush on;
	keepalive_timeout 3000;
	gzip on;
	gzip_min_length 1k;
	gzip_buffers 4 16k;
	gzip_comp_level 2;
	gzip_types text/plain application/x-javascript text/css application/xml;
	gzip_vary on;
	proxy_set_header        Host \$host;
	proxy_set_header        X-Real-IP \$remote_addr;
	client_max_body_size    10m;
	client_body_buffer_size 256k;
	proxy_connect_timeout   3000;
	proxy_send_timeout      3000;
	proxy_read_timeout      3000;
	proxy_buffer_size       16k;
	proxy_buffers           4 32k;
	proxy_busy_buffers_size 64k;
	proxy_temp_file_write_size 64k;
	include server/* ;
}
EOF
	[ ! -d $NginxPath/conf/server ] && mkdir -p --mode=775 $NginxPath/conf/server/
	cat >$NginxPath/conf/server/tomcat.comf<<EOF
server{
    listen 80;
    server_name $ServerHostName;
    location / {
		proxy_pass http://$ServerIP:8080;
    }
}
EOF
	chown www-data:www-data $NginxPath/conf/server/*
	chmod 775 $NginxPath/conf/server/*
	$NginxPath/sbin/nginx
}
#main
SELECT_NGINX_TOMCAT_FUNCTION(){
	clear;
	echo "[Notice] Which tomcat's version you want to install:"
	select var in "tomcat6" "tomcat7" "just nginx and proxy other ip" "back";do
		case $var in
			"tomcat6")
				TomcatVersion="tomcat6" && NGINX_INSTALL && NGINX_CONF_SET;;
			"tomcat7")
				TomcatVersion="tomcat7" && NGINX_INSTALL && NGINX_CONF_SET;;
			"just nginx and proxy other ip")
				echo "Please input proxy tomcat's ip:";read ServerIP;
				TomcatVersion="" && NGINX_INSTALL && NGINX_CONF_SET;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_NGINX_TOMCAT_FUNCTION;;
		esac
		break
	done
}