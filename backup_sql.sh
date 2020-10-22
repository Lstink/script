#!/bin/bash
#auto backup mysql
#@lstink 2020-4-7
#定义变量
BAKDIR=/data/backup/mysql/`date +%Y-%m-%d`
MYSQLDB=wordpress
MYSQLUSR=root
MYSQLPW=95811yyy
if [ $UID -ne 0 ] ; then
	echo '必须使用root用户运行此脚本！！！'
	sleep 2
	exit 0
fi
#判断备份的目录是否存在，如果不存在则新建
if [ ! -d $BAKDIR ] ; then
	mkdir -p $BAKDIR
else
	echo "${BAKDIR}目录存在"
fi
#使用mysqldump命令备份数据库
/usr/local/mysql/bin/mysqldump  -u$MYSQLUSR -d $MYSQLDB -p >$BAKDIR/wordpress.sql
cd $BAKDIR ; tar -czf wordpress_sql.tar.gz *.sql
#查找备份目录下的.sql结尾的文件并删除
find . -type f -name *.sql -exec rm -rf {} \;
[ $? -eq 0 ] && echo "This `date +%Y-%m-%d` 数据库备份成功！"
#删除备份目录30天以前的目录
cd /data/backup/mysql ; find . -type d -mtime +30 | xargs rm -rf
echo '数据库备份成功！'

