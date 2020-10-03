#!/bin/bash

RED=31
GREEN=32
#颜色
function colorAdd ()
{
	echo -e "\033[1;$1m$2\033[0m"
}

#测试默认目录是否存在
function testDirExists ()
{
	if [ ! -d $1 ]; then
		colorAdd "$RED" '目录不存在，请确认后重新输入！'
	fi
}

