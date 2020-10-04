#!/bin/bash
#author: lstink
#time: 2020-10-3
#desc: svn脚本控制

RED=31
GREEN=32
BLUE=44
#svn的版本库目录
SVN_PATH=/usr/svn/
#公网ip地址
IP=39.107.50.238
#端口
PORT=3690
#用户起始行
USERLINE=4

#颜色
function colorAdd ()
{
	echo -e "\033[1;$1m$2\033[0m"
}

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

	#检查版本库名称是否重复
	if [ -d $SVN_PATH$project ]; then
		colorAdd "$RED" "名称为 $project 的版本库已存在，请换一个名称！"
		createProject
	fi

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
			echo '版本库地址为：'
			colorAdd "$BLUE" "svn://$IP:$PORT/$project";
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
	read -p "确认删除 $project 版本库吗？(y/n): " confirm
	case "$confirm" in
		y|Y ) 
		rm -rf $SVN_PATH$project
		if [ $? -eq 0 ]; then
			colorAdd "$GREEN" '版本库删除成功!'
		fi
			;;
		* )
		deleteProject ;;
	esac
	init
}

#添加用户的方法
function createUser(){
	read -p '请输入用户名: ' user
	until [ -n "$user" ]
	do
		read -p '请输入用户名: ' user
	done

	#检查用户是否重复
	grep "$user = " "${SVN_PATH}passwd" &>> /etc/null
	if [ $? -eq 0 ]; then
		colorAdd "$RED" "用户 $user 已存在，请检查！"
		createUser
	fi

	read -p '请输入密码: ' password
	until [ -n "$password" ]
	do
		read -p '请输入密码: ' password
	done
	echo "$user = $password" >> ${SVN_PATH}passwd
	if [ $? -eq 0 ]; then
		colorAdd "$GREEN" '用户添加成功！';
		#添加读写权限
		echo "$user = rw" >> ${SVN_PATH}authz;
		echo '请牢记账号密码：'
		colorAdd "$BLUE" "账号：$user"
		colorAdd "$BLUE" "密码：$password"
	fi
	init
}

#删除用户
function deleteUser(){
	read -p '请输入将要删除的用户名: ' user
	until [ -n "$user" ]
	do
		read -p '请输入将要删除的用户名: ' user
	done

	#检查用户
	grep "$user = " "${SVN_PATH}passwd" &>> /etc/null
	if [ ! $? -eq 0 ]; then
		colorAdd "$RED" "用户 $user 不存在，请检查！"
		deleteUser
	fi

	read -p "确认删除用户 $user 吗？(y/n): " confirm
	case "$confirm" in
		y|Y ) 
		#删除用户以及对应的权限
		deleteAuth $user ;;
		* )
		deleteUser ;;
	esac
	init
}

#查看所有用户
function allUser(){
	sed -n "$USERLINE,$"p ${SVN_PATH}passwd | awk '{print $1}'
	echo ''
	init
}

#查看所有项目
function allProject(){
	find "$SVN_PATH" -type d | awk -F/ '{print $4}' | sort | uniq | awk '{if(NF>0) print $0}'
	echo ''
	init
}

#重置用户密码
function changeUser(){
	read -p '请输入用户名: ' user
	until [ -n "$user" ]
	do
		read -p '请输入用户名: ' user
	done
	#判断该用户是否存在
	grep "$user = " "${SVN_PATH}passwd" &>> /etc/null
	if [ ! $? -eq 0 ]; then
		colorAdd "$RED" "用户 $user 不存在，请检查！"
		changeUser
	fi
	read -p '请输入新密码: ' password
	until [ -n "$password" ]
	do
		read -p '请输入新密码: ' password
	done
	#修改密码
	sed -i "s/$user\s=\s.*/$user = $password/g" ${SVN_PATH}passwd
	if [ $? -eq 0 ]; then
		colorAdd "$GREEN" '密码重置成功！'
	fi
	init
}


#删除用户权限
function deleteAuth(){
	sed -i "/$1\s=\s/d" ${SVN_PATH}passwd && sed -i "/$1\s=\s/d" ${SVN_PATH}authz
	if [ $? -eq 0 ]; then
		colorAdd "$GREEN" '用户删除成功!'
	fi
}

#初始化
function init(){
	cat <<-EOF
	请选择：
	1.创建项目版本库
	2.添加用户(默认拥有读写权限)
	3.删除版本库
	4.删除用户
	5.重置用户密码
	6.查看所有用户
	7.查看所有项目
	q.退出
	EOF

	read -p '选项(默认为1): ' option

	case "$option" in
		1) createProject ;;
		2) createUser ;;
		3) deleteProject ;;
		4) deleteUser ;;
		5) changeUser ;;
		6) allUser ;;
		7) allProject ;;
		q) exit ;;
		*) init ;;
	esac
}

init

#创建成功重启svn
echo '完毕！';

