##如何整合新增的脚本
参考写法,以下方片段代码为例：   

* 在已经定义好的选项列表**"VarLists"**加入你要整合的功能名（前提下你必须要准备好对应的脚本）
* 调用公共函数**"SOURCE_SCRIPT"**来加载你的脚本。

   ---

	if $cn ;then
		echo "[Notice] 请选择要运行的指令:"
		VarLists=("退出" "软件安装" "系统设置" "生成脚本工具" "系统报告")
	else
		echo "[Notice] Which function you want to run:"
		VarLists=("Exit" "Sofeware_Install" "System_Setup" "Create_Script" "System_Report")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				SOURCE_SCRIPT $FunctionPath/sofeinstall.sh
				SELECT_SOFE_INSTALL;;
			${VarLists[2]})
				SOURCE_SCRIPT $FunctionPath/system_setup.sh
				SELECT_SYSTEM_SETUP_FUNCTION;;
			${VarLists[3]})
				SOURCE_SCRIPT $FunctionPath/create_tools.sh
				SELECT_TOOLS_CREATE;;
			${VarLists[4]})
				SOURCE_SCRIPT $FunctionPath/report_system.sh
				SELECT_REPORT_CREATE;;
			${VarLists[0]})
				exit 0;;
			*)
				SELECT_RUN_SCRIPT;;
		esac
		break
	done

---