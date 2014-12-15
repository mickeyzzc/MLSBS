#MLSBS
---
###MLSBS is the abbreviation of "My linux's bash script"!
**MLSBS** 是“My linux's bash script”的缩写 。（经过在Centos6.5 和Ubuntu12.04下测试通过。）  

---
**运行方式：**  
下载项目后，进入项目根目录  
 >  # chmod +x ./myscript.sh  
 >  # ./myscript.sh  

运行前请根据自身系统情况更改配置文件config , 脚本统一使用utf-8编码。  

---

**目录结构：**

mlsbs/  
├── bashScript #独立使用的bash脚本    
├── Template #Bash脚本模板  
├── function #功能函数  
│	 /  ├─ install #软件安装函数  
│    /  └─ system  #系统设置函数  
│  
├── py2script #python2脚本  
├── doc #版本说明和功能介绍  
└── mylib #公共库

