#!/bin/bash
#base puppet's parameter
PUPPET_VAR(){
	PuppetApplication=""
	PuppetServer=""
	PuppetVersion="puppet-3.4.2"
	FacterVersion="facter-1.7.5"
	RubyVersion="ruby-2.0.0-p353"
	OpenSSLVersion="openssl-1.0.1f"
	PupetServerIp=""
}
#install ruby
RUBY_INSTALL(){
	cd /tmp
	[ ! -f $RubyVersion.tar.gz ] && curl -O ftp://ftp.ruby-lang.org/pub/ruby/$RubyVersion.tar.gz
	[ ! -f $OpenSSLVersion.tar.gz ] && curl -O ftp://ftp.openssl.org/source/$OpenSSLVersion.tar.gz
	tar xzf $RubyVersion.tar.gz
	tar xzf $OpenSSLVersion.tar.gz
	cd /tmp/$OpenSSLVersion &&
	./Configure linux-x86_64 --shared &&
	make && make install
	mv /usr/bin/openssl{,.old}
	ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
	cd /tmp/$RubyVersion &&
	./configure --with-openssl-dir=/usr/local/ssl --enable-shared &&
	make && make install
}

#install puppet's base packages
PUPPET_BASE_PACKAGES_INSTALL(){
	#install base packages
	[ "$SysName" == 'centos' ] && BasePackages="curl chkconfig gcc make ntp curl-devel zlib-devel perl perl-devel" || BasePackages="curl chkconfig gcc make ntpdate zlib1g-dev libcurl4-openssl-dev "
	INSTALL_BASE_PACKAGES $BasePackages
	#check ruby install
	ruby -v && RubyOldVersion=`ruby -v |awk '{printf "%s\n",$2}'` 
	[[ "$RubyOldVersion" == '' ]] && RUBY_INSTALL
	#set system hostname
	[[ "$PuppetServer" == '' ]] && read -p "Please input PuppetServer's name:" PuppetServer
	[[ "$PupetServerIp" == '' ]] && read -p "Please input PuppetServer's IP:" PupetServerIp
	HostSet=`grep '$PuppetServer' /etc/hosts`
	[[ "$HostSet" == "" ]] && echo "$PupetServerIp $PuppetServer" >> /etc/hosts || sed -i "s/$HostSet/$PupetServerIp $PuppetServer/g" /etc/hosts
	#call other funtion to set system timezone
	TIMEZONE_SET
	#[ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
}
#now install puppet
PUPPET_SOURCE_INSTALL(){
	PUPPET_BASE_PACKAGES_INSTALL
	cd /tmp
	[ ! -f $FacterVersion.tar.gz ] && curl -O https://downloads.puppetlabs.com/facter/$FacterVersion.tar.gz
	[ ! -f $PuppetVersion.tar.gz ] && curl -O https://downloads.puppetlabs.com/puppet/$PuppetVersion.tar.gz
	tar xzf $FacterVersion.tar.gz
	tar xzf $PuppetVersion.tar.gz
	cd /tmp/$FacterVersion
	ruby install.rb
	cd /tmp/$PuppetVersion
	ruby install.rb
	sudo puppet resource group puppet ensure=present
	sudo puppet resource user puppet ensure=present gid=puppet shell='/sbin/nologin'
	if [[ "$SysName" == 'centos' ]]; then
		[[ "$PuppetApplication" == 'puppetmaster' ]] && cp -af /tmp/$PuppetVersion/ext/redhat/server.init /etc/init.d/$PuppetApplication || cp -af /tmp/$PuppetVersion/ext/redhat/client.init /etc/init.d/$PuppetApplication 
	else
		if [[ "$PuppetApplication" == 'puppetmaster' ]]; then
			cp -af /tmp/$PuppetVersion/ext/debian/puppetmaster.init /etc/init.d/$PuppetApplication
			cp -af /tmp/$PuppetVersion/ext/debian/puppetmaster.default /etc/default/$PuppetApplication
		else
			cp -af /tmp/$PuppetVersion/ext/debian/puppet.init /etc/init.d/$PuppetApplication
			cp -af /tmp/$PuppetVersion/ext/debian/puppet.default /etc/default/$PuppetApplication
		fi
		ln -s /usr/local/bin/puppet /usr/bin/puppet
	fi
}
#puppet's configure setup
PUPPET_SET(){
	[ ! -f /etc/puppet/puppet.conf ] && touch /etc/puppet/puppet.conf && echo >/etc/puppet/puppet.conf
cat >/etc/puppet/puppet.conf <<EOF
[main]
	server = $PuppetServer
	logdir = /var/log/puppet
	rundir = /var/run/puppet
	ssldir = \$vardir/ssl
[agent]
	classfile = \$vardir/classes.txt
	localconfig = \$vardir/localconfig
[master]
EOF
	if [[ "$PuppetApplication" == 'puppetmaster' ]]; then
		sed -i "/main/a certname = $PuppetServer" /etc/puppet/puppet.conf
		#sed -i "/master/a autosign = ture" /etc/puppet/puppet.conf
	else
		sed -i "/agent/a listen = true" /etc/puppet/puppet.conf
		sed -i "1 i path /run\nauth any\nmethod save\nallow $PuppetServer" /etc/puppet/auth.conf
	fi
	chmod +x /etc/init.d/$PuppetApplication
	service $PuppetApplication start
}
#main
SELECT_PUPPET_FUNCTION(){
	clear;
	echo "[Notice] How to set up puppet:"
	select var in "Puppet server install" "Puppet client install" "back";do
		case $var in
			"Puppet server install")
				PuppetApplication='puppetmaster';;
			"Puppet client install")
				PuppetApplication='puppet';;
			"back")
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_PUPPET_FUNCTION;;
		esac
		break
	done
	[[ "$PuppetApplication" != '' ]] && && PUPPET_SOURCE_INSTALL && PUPPET_SET
}
