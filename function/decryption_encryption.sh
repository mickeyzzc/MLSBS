#!/bin/env bash

ENCRY_GZEXE(){
	TEST_PROGRAMS gzexe
	[ $? -gt 0 ] && gzexe $1
	rm -rf $1~
}

