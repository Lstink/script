#!/bin/bash

source ~/script/fun.sh
VHOSTDIR="/usr/local/etc/nginx/vhosts"
REWRITEDIR="/usr/local/etc/nginx/rewrite/"
REWRITEARRAY=('thinkPhp' 'laravel' 'yii')

#测试默认目录是否存在
function testVhostsExists ()
{
	if [ ! -d $1 ]; then
		colorAdd "$RED" '目录不存在，请确认后重新输入！'
		vhostDir=''
	fi
}


read -p "请输入域名: " serverName
while [[ ! -n "$serverName" ]]; do
	read -p "请输入域名: " serverName
done

read -p "请输入项目配置目录: " documentRoot
while [[ ! -n "$documentRoot" ]]; do
	read -p "请输入项目配置目录: " documentRoot
done
#虚拟主机的配置目录
read -p "请输入虚拟主机配置目录（默认为：${VHOSTDIR}）: " vhostDir
if [[ ! -n "$vhostDir" ]]; then
	#测试默认目录是否存在
	if [ ! -d "$VHOSTDIR" ]; then
		colorAdd "$RED" '默认目录不存在，请指明虚拟主机文件配置目录！'
		while [[ ! -n "$vhostDir" ]]; do
			read -p "请输入虚拟主机文件配置目录: " vhostDir
			#测试指定目录是否存在
			testVhostsExists $vhostDir
		done
	else
		vhostDir="$VHOSTDIR"
	fi
else
	#测试指定目录是否存在
	testVhostsExists $vhostDir
	while [[ ! -n "$vhostDir" ]]; do
		read -p "请输入虚拟主机文件配置目录: " vhostDir
		#测试指定目录是否存在
		testVhostsExists $vhostDir
	done
fi


#php版本
read -p "是否选择php版本(默认为php7.2，y/n): " version
if [[ "$version" == "y" || "$version" == "Y" ]]; then
	#配置php版本
	echo -e "1.\033[1;32mphp7.2\033[0m"
	echo -e "2.\033[1;32mphp7.4\033[0m"
	read -p "请输入选项(1或者2): " version
	while [[ ! -n "$version" ]]; do
		read -p "请输入选项(1或者2): " version
	done
	if [[ "$version" == '2' ]]; then
		version="74"
	else
		version="72"
	fi
else
	version="72"
fi

#重写规则
read -p "是否配置重写规则(y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
	#配置重写规则
	echo -e "1.\033[1;32mthinkphp\033[0m"
	echo -e "2.\033[1;32mlaravel\033[0m"
	echo -e "3.\033[1;32myii\033[0m"
	read -p "请输入选项(1|2|3): " rewrite
	while [[ ! -n "$rewrite" ]]; do
		read -p "请输入选项(1|2|3): " rewrite
	done
	if [[ "$rewrite" == '1' ]]; then
		rewrite="${REWRITEDIR}thinkphp.conf"
	fi

	if [[ "$rewrite" == '2' ]]; then
		rewrite="${REWRITEDIR}laravel.conf"
	else
		rewrite="${REWRITEDIR}yii.conf"
	fi
else
	rewrite="${REWRITEDIR}none.conf"
fi


#创建文件并写入
cd $vhostDir
fileName="${serverName}.conf"
touch "${fileName}"
cat > "$fileName" <<-EOF
server {
  listen 80;
  server_name $serverName;
  #access_log /usr/local/var/log/nginx/access.log combined;
  index index.php index.html index.htm;
  root $documentRoot;

  include $rewrite;
  #error_page 404 /404.html;
  #error_page 502 /502.html;

  location ~ [^/]\.php(/|$) {
    #fastcgi_pass 127.0.0.1:9000;
    fastcgi_pass unix:/tmp/php-cgi-$version.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
  }

  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
    expires 30d;
    access_log off;
  }
  location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
  }
  location ~ /\.ht {
    deny all;
  }
}
EOF

if [[ $? == 0 ]]; then
	colorAdd "$GREEN" '虚拟主机创建成功！'
	`nginx -s reload`
	if [[ $? == 0 ]]; then
		colorAdd "$GREEN" 'nginx已重启'
	fi
else
	colorAdd "$RED" '虚拟主机创建失败！'
fi






