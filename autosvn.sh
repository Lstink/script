#!/bin/bash

RED=31
GREEN=32
#颜色
function colorAdd ()
{
	echo -e "\033[1;$1m$2\033[0m"
}
#svn的版本库目录
SVN_PATH=/usr/svn/

#创建版本库的方法
function createProject(){
	if [ $UID -ne 0 ]; then
		colorAdd "$RED" '请使用root账号登录'
		exit
	fi
	read -p '请输入项目名称: ' project
	until [ -n "$project" ]
	do
		read -p '请输入项目名称: ' project
	done
	#创建项目版本库
	svnadmin create $SVN_PATH$project

	if [ $? -eq 0 ]; then
		#修改配置
		cat > $SVN_PATH${project}/conf/svnserve.conf <<-EOF
			[general]
			anon-access = none
			auth-access = write
			password-db = /usr/svn/passwd
			authz-db = /usr/svn/authz
		EOF
		echo "realm = $project" >> $SVN_PATH${project}/conf/svnserve.conf;
		if [ $? -eq 0 ]; then
			colorAdd "$GREEN" '自动创建项目版本库成功!';
		fi
	else
		#创建失败
		colorAdd "$RED" '版本库创建失败，请确认是否安装svn？'
	fi
	init
}

#删除版本库的方法
function deleteProject(){
	read -p '请输入要删除的版本库名称: ' project
	until [ -n "$project" ]
	do
		read -p '请输入要删除的版本库名称: ' project
	done
	if [ ! -d $SVN_PATH$project ]; then
		colorAdd "$RED" "${project}版本库不存在，请检查确认"
		deleteProject
	fi
	rm -rf $SVN_PATH$project
	if [ $? -eq 0 ]; then
		colorAdd "$GREEN" '版本库删除成功!'
	fi
	init
}

#添加用户的方法
function createUser(){
	read -p '请输入用户名: ' user
	until [ -n "$user" ]
	do
		read -p '请输入用户名: ' user
	done
	read -p '请输入密码: ' password
	until [ -n "$password" ]
	do
		read -p '请输入密码: ' password
	done
	echo "$user = $password" >> ${SVN_PATH}passwd
	if [ $? -eq 0 ]; then
		colorAdd "$GREEN" '用户添加成功！';
	fi
	init
}

#初始化
function init(){
	cat <<-EOF
	请选择：
	1.创建项目版本库
	2.添加用户(默认拥有读写权限)
	3.删除版本库
	4.退出
	EOF

	read -p '选项(默认为1): ' option

	case "$option" in
		1) createProject ;;
		2) createUser ;;
		3) deleteProject ;;
		*) exit ;;
	esac
}

init

#创建成功重启svn
echo '完毕！';

