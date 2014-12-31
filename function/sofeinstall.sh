#! Encoding UTF-8
SELECT_SOFE_INSTALL(){
	SOURCE_SCRIPT $FunctionPath/report_system.sh
	CPU_VALUES
	RAM_VALUES
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择要安装软件:"
		VarLists=("返回首页" "安装nginx" "安装tomcat" "安装mysql" "安装puppet")
	else
		echo "[Notice] Which sofeware are you want to install:"
		VarLists=("Back" "Install_nginx" "Install_tomcat" "Install_Mysql" "Install_Puppet")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				SOURCE_SCRIPT $FunctionPath/install/nginx_install.sh
				NGINX_VAR
				SELECT_NGINX_FUNCTION 2>>${ErrLog};;
			${VarLists[2]})
				SOURCE_SCRIPT $FunctionPath/install/tomcat_install.sh
				TOMCAT_VAR
				SELECT_TOMCAT_FUNCTION 2>>${ErrLog};;
			${VarLists[3]})
				SOURCE_SCRIPT $FunctionPath/install/mysql_install.sh
				MYSQL_VAR 
				MYSQL_BASE_PACKAGES_INSTALL 2>>${ErrLog}
				INSTALL_MYSQL 2>>${ErrLog};;
			${VarLists[4]})
				SOURCE_SCRIPT $FunctionPath/install/puppet_install.sh
				PUPPET_VAR
				SELECT_PUPPET_FUNCTION 2>>${ErrLog};;
			${VarLists[0]})
				SELECT_RUN_SCRIPT;;
			*)
				SELECT_SOFE_INSTALL;;
		esac
		break
	done
}