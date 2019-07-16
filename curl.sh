#!/bin/bash
#查看文件中网站是否连通，url命令
#作者：oOLLMOo
#版本：1.0
#Email:timmyl16@163.com

while true
do
 false=0
 Retval=0
Geturlstat() {
	 for ((i=1;i<=3;i++))
	 do
		curl -I -s http://${1} >/dev/null 2>&1
		[ $? -ne 0 ]&& let false+=1;
	done
	
	if [ $false -gt 1 ]; then
		Retval=1
		Date=`date +%F" "%H:%M`
		echo -e "Date:$Date\nProblem: $url is not running."
	else
		Retval=0
	fi
		return $Retval
}
for url in `cat url.txt | sed '/^#/d'`
	do
		Geturlstat $url
	done
	sleep 2m
done
