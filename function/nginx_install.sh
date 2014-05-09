#!/bin/bash

NGINX_VAR(){
	NginxVersion="nginx-1.4.5"
	NginxPath="/usr/local/nginx"
	ServerIP=""
	ServerHostName=""
	[[ "$ServerHostName" == '' ]] && read -p "Please input domain name:" ServerHostName
}
NGINX_BASE_PACKAGES_INSTALL(){
	if [ "$SysName" == 'centos' ] ;then
		yum -y remove httpd;
		BasePackages="pidof gcc gcc-c++ openssl-devel pcre pcre-devel zlib-devel zlib make openssl";
	else
		apt-get -y remove nginx apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker;
		BasePackages="pidof gcc g++ make libpcre3 libpcre3-dev libssl-dev zlibc openssl zlib1g zlib1g-dev";
	fi
	INSTALL_BASE_PACKAGES $BasePackages
	kill -9 `pidof nginx`
}
NGINX_INSTALL(){
	NGINX_BASE_PACKAGES_INSTALL
	groupadd www-data;
	useradd -s /sbin/nologin -g www-data www-data;
	cd /tmp/
	[ ! -f $NginxVersion.tar.gz ] && curl -O http://nginx.org/download/$NginxVersion.tar.gz
	tar zxf $NginxVersion.tar.gz
	cd /tmp/$NginxVersion
	./configure  --prefix=$NginxPath --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --conf-path=$NginxPath/conf/nginx.conf --with-mail --with-mail_ssl_module
	make && make install
}
NGINX_CONF_SET(){
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
	chown -R www-data:www-data $NginxPath
	chmod -R 775 $NginxPath
	$NginxPath/sbin/nginx
}
#main
SELECT_NGINX_FUNCTION(){
	clear;
	echo "[Notice] Which tomcat's version you want to install:"
	select var in "with localhost's tomcat" "without localhost's tomcat" "back";do
		case $var in
			"with localhost's tomcat")
				ServerIP="127.0.0.1";;
			"without localhost's tomcat" )
				echo "Please input proxy tomcat's ip:";read ServerIP;;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_NGINX_FUNCTION;;
		esac
		break
	done
	[[ "$ServerIP" != '' ]] && NGINX_INSTALL && NGINX_CONF_SET
}
