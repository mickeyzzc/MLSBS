#MLSBS
MLSBS is the abbreviation of "My linux's bash script"!

“MLSBS”是“My linux's bash script”的缩写
linux运维技术人员日常需要写一堆脚本来简化工作量。“MLSBS”的目的就是把我日常在linux下的工作通过脚本整合到一个项目中，需要的时候几个点击就可以完成任务了。（其实，写这脚本的最初原因是，我有一些搞开发朋友在某些IDC提供的虚拟服务上部署他们的应用，有时会叫我帮忙初始化环境，所以写了这个项目提供给他们使用）
由于我一个人时间有限，将以往的运维脚本整合的进度有点慢。暂时提供一键安装几个常用软件的功能。
目前脚本的目录如下：（经过在centos6.5 和ubuntu12.04下测试通过。）

mlsbs/
├── config #基本配置内容
├── function #被调用的函数目录
│   ├── config_python.sh #未完成
│   ├── iptables_set.sh #包过滤软件iptables交互设置
│   ├── mysql_install.sh #mysql源码数据库安装
│   ├── nginx_install.sh #nginx源码安装
│   ├── puppet_install.sh #puppet服务端和客户端安装配置
│   ├── report_system.sh #未完成
│   ├── system_base_set.sh #系统基本配置
│   └── tomcat_install.sh #tomcat自动部署
├── LICENSE
├── myscript.sh #main执行文件
├── py2script #python2脚本
│   ├── myconfig.conf #python配置文件
│   ├── myftp.py #ftp可续传的上传下载脚本
│   └── sendmail.py #邮件发送脚本
├── README.md
└── bashScript #独立使用的bash脚本
    ├── curl_url.sh
    ├── mysqlclient.sh
    └── mysqlserver.sh
