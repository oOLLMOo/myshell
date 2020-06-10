#!/bin/bash
#作者：LLM(Timothy Luo)
#主机名修改脚本

stty erase '^H'  #####read语句前转化退格符

while true
do
read -p "是否要修改gitlab-ce的主机名url？（Y/N）：" answer
case $answer in
	Y|y)
	while true
	do
	read -p "输入新的主机名(如果需要重新修改可运行hostmod.sh脚本，只需写主机名和端口，默认http协议)：" new_url
	##sed -i 's/external_url .*/external_url '\'''$new_url''\''/g' /etc/gitlab/gitlab.rb
	sed -i 's/^external_url .*/external_url '\''http:\/\/'$new_url''\''/g' /etc/gitlab/gitlab.rb
	if [ $? -eq 0 ]
	then echo "修改成功！"
	echo "【通知】您之后可以通过执行安装程序包的hostmod.sh重新设置主机名"
	break
	fi
	done
	break
	;;
	N|n)break;;
	*)continue;;
esac
done
