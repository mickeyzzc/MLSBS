##公共库
###默认：
* EXIT_MSG  
输出错误信息提示，同时生成日志并退出程序。用法： 

  		#当系统名为空时，生成错误提示，自动检测系统是否支持中文，如支持，就输出第一项提示，如否则输出第二项提示。
		[[ "$SysName" == '' ]] && EXIT_MSG "程序不支持在此系统上运行。" "Your system is not supported this script"

* INFO_MSG  
输出一般信息提示，同时生成日志。用法：

		#输出提示"加载库"，自动检测系统是否支持中文，如支持，就输出第一项提示，如否则输出第二项提示。
		INFO_MSG "正在加载库: $arg ......" "loading $arg now, continue ......"

* SOURCE_SCRIPT   
加载功能项脚本。用法：

		#加载sofeinstall.sh脚本，并调用其中的SELECT_SOFE_INSTALL函数。
		SOURCE_SCRIPT $FunctionPath/sofeinstall.sh
		SELECT_SOFE_INSTALL;;

---
###common:
* PASS_ ENTER_ TO_EXIT   
请按回车后继续，否则10秒内自动下一步。
* TEST_FILE  
测试文件的存在，如存在就返回0，不存在返回1 。
* TEST_PROGRAMS  
测试程序的存在，如存在就返回0，不存在返回1 。
* BACK_TO_INDEX  
返回首页。
* INPUT_CHOOSE  
选择输入。
* TEST_ROOT  
检测当前用户是否root权限用户。
* INSTALL_BASE_PACKAGES  
安装软件函数，自识别系统自动调用apt或者yum来安装程序。
* INSTALL_BASE_CMD  
分别调用TEST_PROGRAMS和INSTALL_BASE_PACKAGES来安装命令工具。
* PACKET_TOOLS  
打包python工具为安装包的函数，需要配合解压安装脚本同时使用。