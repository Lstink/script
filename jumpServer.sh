#!/bin/bash
cat <<-EOF
+-------------------------------------------+
|		JumpServer by Lstink				|
|		1.Login in zs's Server				|
|		2.Login in ZhangXin's Server		|
|		3.Exit								|
+-------------------------------------------+
EOF
read -p 'Please input your server: ' num
while [[ ! "$num" =~ ^[123]$ ]] ; do
	echo -e "\033[1;31mError number! Example : [1/2/3]\033[0m";
	read -p 'Please input your server: ' num
done
case "$num" in
"1")
	ssh root@39.105.56.155
;;
"2")
	ssh root@182.92.105.108
;;
"3")
	exit
;;
esac


