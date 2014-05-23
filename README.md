#MLSBS
MLSBS is the abbreviation of "My linux's bash script"!
“MLSBS”是“My linux's bash script”的缩写 linux运维技术人员日常需要写一堆脚本来简化工作量。“MLSBS”的目的就是把我日常在linux下的工作通过脚本整合到一个项目中，需要的时候几个点击就可以完成任务了。

由于一个人时间有限，将以往的运维脚本整合的进度有点慢。暂时提供一键安装几个常用软件的功能。 目前脚本的目录如下：（经过在centos6.5 和ubuntu12.04下测试通过。）

版本说明：
v0.1版本：为初始版本，只提供基本的日常运维软件的简单部署功能，目前还有很多脚本没有整合起来；
新增开发分支：新增bash脚本模板，将较优秀和常用的脚本模板化，根据需求生成cron任务。模板路径（bashTemplate）
v0.2版本：这个版本纯属为了凑热闹，和某些IT企业发布新品的这个2014年5月15日日子里发布而已，对比v0.1版本增加了Crontab任务的添加功能，目前增加两个任务脚本。同时也修复了mysql在10G以下硬盘安装后无法启动的BUG。

目录结构：
mlsbs/
├── bashScript #独立使用的bash脚本
│   ├── curl_url.sh
│   ├── mysqlclient.sh
│   └── mysqlserver.sh
├── bashTemplate #Bash脚本模板
│   ├── mysql_server.sh #处理mysql服务器的日常任务脚本
│   └── ssh_backlist_deny.sh #ssh黑名单生成任务脚本
│   └── system_check.sh #硬盘空间检测任务脚本
├── config#脚本配置文件
├── function#被调用的函数目录
│   ├── config_python.sh
│   ├── create_cron.sh #生成日常任务
│   ├── iptables_set.sh #包过滤软件iptables交互设置
│   ├── mysql_install.sh #mysql源码数据库安装
│   ├── nginx_install.sh #nginx源码安装
│   ├── puppet_install.sh #puppet服务端和客户端安装配置
│   ├── report_system.sh
│   ├── system_base_set.sh #系统基本配置
│   └── tomcat_install.sh #tomcat自动部署
│   └── decryption_encryption.sh #加密解密程序
├── LICENSE
├── myscript.sh #main执行文件
├── py2script #python2脚本
│   ├── myconfig.conf
│   ├── myftp.py
│   └── sendmail.py
└── README.md