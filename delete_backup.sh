#!/bin/bash

time=$(date "+%Y-%m-%d %H:%M:%S")
LOG_PATH=/www/wwwroot/shop-jtgj-cc/storage/logs/
DB_PATH=/www/wwwroot/shop-jtgj-cc/storage/app/backup/

find "$LOG_PATH" -mtime +7 -name "*.log" -exec rm -rf {} \;

if [[ $? == 0 ]] ; then
	echo "$time - 日志文件删除成功"
	find "$DB_PATH" -mtime +7 -name "*.zip" -exec rm -rf {} \;
	if [[ $? == 0 ]]; then
		echo "$time - 数据库备份文件删除成功"
	else
		echo "$time - 数据库备份文件删除失败"
	fi
else
	echo "$time - 日志文件删除失败"
fi
