#!/bin/bash
source ~/script/fun.sh
#定义变量

START=/Volumes/code/gaopin/yzbproject/dist/
END=/Volumes/code/gaopin/dongyiyixue/public/
#定义函数
#打包成功之后移动代码
function cpFile ()
{
	cp -rf /Volumes/code/gaopin/yzbproject/dist/* "$END"
	if [[ $？ == 1 ]]; then
		colorAdd "$RED" '文件移动失败！'
	fi
	#切换目录
	cd $END
	rm -rf favicon.ico
	mv ./index.html ./themes/simpleboot3/portal/
	if [[ $? == 0 ]]; then
		colorAdd "$GREEN" '本地部署成功！'
	fi

	cd ../ && git add -A && git commit -m '前端' && git push
	if [[ $? == 0 ]]; then
		colorAdd "$GREEN" '代码推送成功！'
	fi
}
##线上部署
function upLine ()
{
	#部署服务器
	ssh root@112.126.81.1 "cd /www/wwwroot/zhuanyibo && git pull &> /etc/null"
	if [[ $? == 0 ]]; then
		colorAdd "$GREEN" '服务器部署成功！'
	else
		colorAdd "$RED" '服务器部署失败！请手动部署！'
	fi
}


#拉取前端代码
cd /Volumes/code/gaopin/yzbproject && git pull
#判断代码拉取情况
if [[ $? == 0 ]]; then
	#拉取成功，下载插件
	yarn
	#插件下载情况
	if [[ $? == 0 ]]; then
		colorAdd "$GREEN" '插件下载成功！'
		yarn build
		if [[ $? == 0 ]]; then
			colorAdd "$GREEN" '打包成功！'
			#部署本地
			cpFile
			#部署线上
			read -p '是否部署服务器？[y/n] ' confirm
			case "$confirm" in
				y | Y )
				upLine
				;;
				n | N )
				colorAdd "$RED" '未选择一键部署服务器。请手动部署！'
				;;
			esac
		else
			colorAdd "$RED" '打包失败！'
		fi
	else
		colorAdd "$RED" '插件下载失败！'
	fi
#代码拉取失败
else
	colorAdd "$RED" '代码拉取失败！'
fi



