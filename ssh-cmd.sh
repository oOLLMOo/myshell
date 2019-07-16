#!/bin/bash
#远程执行命令
#作者：oOLLMOo
#版本：1.0
#Email：timmyl16@163.com
#更新：显示ip同时还能显示admin.txt中的注释信息
list="/root/admin.txt"
count=`cat $list | wc -l`

if [ $# -lt 1 ]
then
		echo "useage:ssh-cmd cmd1"
		exit 1
fi

cat -n $list
echo "-----------------------------"
echo "全部执行(Y) 取消(N)"
echo "-----------------------------"

read -p "请输入主机编号：" A

case $A in

	y|Y)for ip in `cat $list | awk '{print $1}'`  #精确匹配，可以在list名单添加注释
		do
		echo -e "++++[\033[32m $ip \033[0m][\033[32m`cat $list | grep $ip | awk -F "#" '{print $2}'`\033[0m]+++++++++++++++++++++"
		ssh $ip $*
		done;;
	n|N)
		echo "任务取消..."
		exit 1
		;;
	*)
		for i in `echo $A`
		do
		if [ $i -gt $count ]
		then echo "输入有误，请重新输入"
			exit 1
		fi
		ip=`cat -n $list | sed -n ''$i'{p}' | awk '{print $2}'`
		echo -e "++++[\033[32m $ip \033[0m][\033[32m`cat $list | grep $ip | awk -F "#" '{print $2}'`\033[0m]+++++++++++++++++++++"
		ssh $ip $*
		done;;
esac
