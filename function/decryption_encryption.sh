#!/bin/env bash

ENCRY_GZEXE(){
	TEST_PROGRAMS gzexe
	[ $? -gt 0 ] && gzexe $1
	rm -rf $1~
}
SHC_INSTALL(){
ShcVersion="shc-3.8.9"
cd /tmp/
[ ! -f $ShcVersion.tgz ] && wget http://www.datsi.fi.upm.es/~frosal/sources/$ShcVersion.tgz
tar vxf /tmp/$ShcVersion.tgz
cd /tmp/$ShcVersion
TEST_PROGRAMS gcc
[ $? -eq 0 ] && INSTALL_BASE_PACKAGES gcc
make test
make strings
make expiration
[ ! -d /usr/local/man/man1/ ] && mkdir -p /usr/local/man/man1/
make install <<EOP
y
EOP
}
ENCRY_SHC(){
	TEST_PROGRAMS shc
	[ $? -eq 0 ] && SHC_INSTALL
	CFLAGS=-static shc -r -f $1
	rm -rf $1 $1~ $1.x.c
	mv $1.x $1
}
SELECT_ENCRY_FUNCTION(){
	clear;
	echo "[Notice] How to encryption your script:"
	select var in "Use gzexe" "Use shc" "Do not encryption";do
		case $var in
			"Use gzexe")
				ENCRY_FUNCTION="ENCRY_GZEXE";;
			"Use shc" )
				ENCRY_FUNCTION="ENCRY_SHC";;
			"Do not encryption")
				ENCRY_FUNCTION="";;
			*)
				SELECT_ENCRY_FUNCTION;;
		esac
		break
	done
}
