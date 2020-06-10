#!/bin/bash
#作者：LLM(Timothy Luo)
#注意：此脚本只能在ubuntu 18.04 LTS运行,需要在root权限下运行
#版本：1.0
###########未完成##########

#时间戳
time=`date +%F-%H-%M-%S`

#ubuntu版本相关变量定义
ubuntu_ver=`lsb_release -r | awk '$1="Release:"{print $2}'`
ubuntu_codename=`lsb_release -c | awk '$1="Codename:"{print $2}'`

#网卡定义
conn=`ip a | grep "\<inet\>" | grep -v "127.0.0.1" | wc -l`

######判定此脚本是否可在当前系统环境运行######
judge(){
if [ $ubuntu_ver == "18.04" ] && [ $ubuntu_codename == "bionic" ]
	then sleep 2 
	     echo "Version and codename... OK!"
	else echo "Version isn't 18.04, Codename isn't bionic" && exit 2 
fi
}

###执行apt源更改
action(){
mv /etc/apt/sources.list /etc/apt/sources.list.backup-$time

cat> /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF

cat> /etc/apt/sources.list.d/gitlab-ce.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu bionic main
EOF
}

####gitlab-ce安装模块####
install(){
curl https://packages.gitlab.com/gpg.key 2> /dev/null | sudo apt-key add - &>/dev/null
apt-get update
apt-get install -y gitlab-ce
}

####gitlab-ce端口转移服务###
port(){
stty erase '^H' 
while true
do
read -p "是否需要配置gitlab的端口(Y/N)" port_1
case $port_1 in
	Y|y)./modify.sh   ###执行端口更改脚本  ./modify.sh
		break;;
	N|n) 
		break;;
	*)  echo "输入有误"
		continue;;
esac
done
}

#######询问是否修改主机名模块######
hostmod(){
stty erase '^H'
while true
do
read -p "是否进入主机名设置（Y/N）:" host_ans
case $host_ans in
	Y|y)./hostmod.sh;;
	N|n)echo "【通知】您之后可以通过执行安装程序包的hostmod.sh重新设置主机名"
	break;;
	*)continue;;
esac
done
}

###启动gitlab-ce####
start(){
while true
do
read -p "安装完毕，是否启动gitlab？（Y/N）:" start_ans
case $start_ans in
	Y|y)
	gitlab-ctl reconfigure
	gitlab-ctl start
	break
	;;
	N|n) echo "您可以通过gitlab-ctl reconfigure; gitlab-ctl start来启动gitlab-ce"
	break
	;;
	*)continue;;
esac
done
}
#######安装程序开头#######
echo "================gitlab-ce安装程序================="
echo "==================作者：LLM===================="
while true
do
read -p "您是否要开始安装ubuntu 18.04版gitlab-ce（在线安装最新版本）？[是:Y 否:N]:" install_ans
case $install_ans in
	Y|y)break;;
	N|n)exit 0;;
	*)continue;;
esac
done

echo "正在检测您的操作系统环境..." && judge
echo "正在配置安装源..." && action
install
echo "正在进入端口设置..."
sleep 1 && port
echo "正在进入主机名设置..."
sleep 1 && hostmod
start
