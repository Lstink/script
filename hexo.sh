#!/bin/bash
source ~/script/fun.sh

cd /Volumes/code/2020/blog/
#cd /Applications/MAMP/htdocs/2020/blog/
hexo clean
hexo g -d

if [[ $? == 0 ]] ; then
	colorAdd "$GREEN" '一键部署成功！'
	if [[ ! -n $1 ]]; then
		read -p '是否部署服务器？[y/n] ' confirm
	else
		confirm="$1"
	fi
	case "$confirm" in
		y | Y )
		#部署服务器
		ssh root@39.105.56.155 "cd /data/wwwroot/yyy/hexo_blog && git pull &>/etc/null"
		if [[ $? == 0 ]]; then
			colorAdd "$GREEN" '服务器部署成功！'
		else
			colorAdd "$RED" '服务器部署失败！请手动部署！'
		fi
		;;
		n | N )
		colorAdd "$RED" '未选择一键部署服务器。请手动部署！'
		;;
	esac
else
	colorAdd "$RED" 'Error stop!'
fi
