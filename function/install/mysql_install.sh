#!/bin/bash
#base mysql's parameter
[ $RamTotal -lt '1000' ] && echo -e "[Error] Not enough memory install mysql.\nThis script need memory more than 1G.\n" && SELECT_RUN_SCRIPT;
MYSQL_VAR(){
	MysqlVersion="mysql-5.6.30"
	MysqlLine="http://cdn.mysql.com/Downloads/MySQL-5.6"
	MysqlPath="$InstallPath/mysql"
	MysqlDataPath="$MysqlPath/data"
	MysqlLogPath="$LogPath/mysql"
	MysqlConfigPath="$MysqlPath"
	MysqlPass=""
	[ -z $MysqlPass ] && read -p "Please input MYSQL's password:" MysqlPass
}
MYSQL_BASE_PACKAGES_INSTALL(){
	if [ "$SysName" == 'centos' ] ;then
		yum -y remove mysql-server mysql;
		BasePackages="wget gcc gcc-c++ autoconf libxml2-devel zlib-devel libjpeg-devel libpng-devel glibc-devel glibc-static glib2-devel  bzip2-devel openssl-devel ncurses-devel bison cmake make";
	else
		apt-get -y remove mysql-client mysql-server mysql-common;
		BasePackages="wget gcc g++ cmake libjpeg-dev libxml2 libxml2-dev libpng-dev autoconf make bison zlibc bzip2 libncurses5-dev libncurses5 libssl-dev";
	fi
	INSTALL_BASE_PACKAGES $BasePackages
}
#install mysql
INSTALL_MYSQL(){
	cd $DownloadTmp
	echo "[${MysqlVersion} Installing] ************************************************** >>";
	[ ! -f ${MysqlVersion}.tar.gz ] && wget -c ${MysqlLine}/${MysqlVersion}.tar.gz
	tar -zxf $DownloadTmp/$MysqlVersion.tar.gz;
	cd $DownloadTmp/$MysqlVersion;
	groupadd mysql;
	useradd -s /sbin/nologin -g mysql mysql;
	cmake -DCMAKE_INSTALL_PREFIX=$MysqlPath -DWITH_DEBUG=OFF -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_READLINE=ON -DENABLED_LOCAL_INFILE=ON -DWITH_INNODB_MEMCACHED=ON -DWITH_UNIT_TESTS=OFF;
	make &&	make install;
	for path in $MysqlLogPath $MysqlPath $MysqlConfigPath/conf.d $MysqlDataPath;do
		[ ! -d $path ] && mkdir -p $path
		chmod 775 $path;
		chown -R mysql:mysql $path;
	done
# EOF **********************************
cat > $MysqlConfigPath/my.cnf<<EOF;
[mysqld]
user		= mysql
server-id	= 1
pid-file	= /tmp/mysql.pid
socket		= /tmp/mysql.sock
port		= 3306
basedir		= $MysqlPath
datadir		= $MysqlDataPath
bind-address	= 0.0.0.0
skip-name-resolve
skip-external-locking
thread_concurrency	= `expr $CpuProNum \* 2`
max_connections	= `expr $FileMax \* $CpuProNum \* 2 / $RamTotal`
max_connect_errors	= 30
table_open_cache	= `expr $RamTotal + $RamSwap`
max_allowed_packet	= `expr $RamTotal \* 2 / 1000`M
binlog_cache_size	= 4M
max_heap_table_size	= `expr $RamTotal / 100`M
sort_buffer_size	= `expr $RamTotal \* 2 / 1000`M
join_buffer_size	= `expr $RamTotal \* 2 / 1000`M
query_cache_size	= `expr $RamTotal / 100`M
thread_cache_size	= 30
thread_concurrency	= `expr $CpuProNum \* 4`
connect_timeout		= 1200
wait_timeout		= 1200
general_log	= 1
general_log_file	= $MysqlLogPath/mysql.log
log_error	= $MysqlLogPath/mysql-err.log
slow_query_log	= 1
slow_query_log_file	= $MysqlLogPath/mysql-slow.log
long_query_time	= 3
log_bin	= $MysqlLogPath/mysql-bin
log_bin_index	= $MysqlLogPath/mysql-bin.index
expire_logs_days	= 7
max_binlog_size	= `expr $(df -m $MysqlLogPath |awk 'NR==2{printf "%s\n",$4}') / 1000`M
default_storage_engine	= InnoDB
innodb_buffer_pool_size	= `expr $RamTotal / 100`M
innodb_log_buffer_size	= 8M
innodb_file_per_table	= 1
innodb_open_files	= `expr $FileMax \* $CpuProNum / $RamTotal`
innodb_io_capacity	= `expr $FileMax \* $CpuProNum / $RamTotal`
innodb_flush_method	= O_DIRECT

!includedir $MysqlConfigPath/conf.d
[mysqld_safe]
open_files_limit	= `expr $FileMax / $CpuProNum / 100`
[isamchk]
key_buffer		= 16M
[mysqldump]
quick
quote-names
max_allowed_packet	= 16M
EOF
# **************************************
	$MysqlPath/scripts/mysql_install_db --user=mysql --defaults-file=$MysqlConfigPath/my.cnf --basedir=$MysqlPath --datadir=$MysqlDataPath;
# EOF **********************************
cat > /etc/ld.so.conf.d/mysql.conf<<EOF
$MysqlPath/lib
EOF
# **************************************
	ldconfig;
	rm -f /usr/lib64/mysql /usr/lib/mysql /etc/init.d/mysqld
	[ "$SysBit" == '64' ] && ln -s $MysqlPath/lib/mysql /usr/lib64/mysql
	[ $? -gt 0 ] && ln -s $MysqlPath/lib/mysql /usr/lib/mysql
	cp $MysqlPath/support-files/mysql.server /etc/init.d/mysqld;
	chmod 775 /etc/init.d/mysqld;
	/etc/init.d/mysqld start;
	for i in mysql mysqladmin mysqlcheck mysqldump;do
		rm -rf /usr/bin/$i
		ln -s $MysqlPath/bin/$i /usr/bin/$i;
	done
	$MysqlPath/bin/mysqladmin password $MysqlPass;
	rm -rf $MysqlDataPath/test;
# EOF **********************************
mysql -hlocalhost -uroot -p$MysqlPass <<EOF
USE mysql;
DELETE FROM user WHERE user='';
UPDATE user set password=password('$MysqlPass') WHERE user='root';
DELETE FROM user WHERE not (user='root');
DROP USER ''@'%';
FLUSH PRIVILEGES;
EOF
# **************************************
	echo "[OK] ${MysqlVersion} install completed.";
}
