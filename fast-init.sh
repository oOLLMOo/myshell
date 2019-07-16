#!/bin/bash
#Date 2019-07-12
#Author: Created by llm
#Function: This scripts function is fastest System-initialization.
#Version: 1.1
#修改：1、修改网卡设置的网关项目 2、在最后新增了阿里源

#Checking the OS version
check(){
echo "Checking your CentOS version..."
sleep 1s
if [ `rpm -q centos-release | awk -F "-" '{print $3}'` -ne 7 ]
	then echo "Not the suitable version of this shell. "
		exit
fi
}

check
 
	#network
	conn=`ip a | grep "\<inet\>" | grep -v "127.0.0.1" | wc -l`
	netname=`ls /sys/class/net/|head -1`  
	getip=`ip a | grep $netname | awk -F "[ /]+" 'NR==2{print $3}'`
	gateway=`ip route show | grep default | awk '{print $3}'`
	
	if [ $conn -eq 0 ]
then
     echo "未检测到当前合法IP地址，请检查网络连接..."   
     exit 123
fi
	
	cat> /etc/sysconfig/network-scripts/ifcfg-$netname <<EOF
TYPE=Ethernet
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
NAME=${netname}
DEVICE=${netname}
ONBOOT=yes
IPADDR=$getip
NETMASK=255.255.255.0
GATEWAY=$gateway
DNS1=202.96.128.86
EOF
	

	systemctl restart network 2>/dev/null 
	

	#disk
	umount /mnt 1>/dev/null 2>&1
	mount  /dev/sr0 /mnt 1>/dev/null 2>&1
	if [ $? -ne 0 ]
	then 
		echo "check your cd-rom , initialization bash break."
		exit 1
	fi
	cat /etc/rc.d/rc.local | grep "/dev/sr0" 1>/dev/null 2>&1 
	if [ $? -ne 0 ]
	then echo "mount -o defaults /dev/sr0 /mnt" >> /etc/rc.d/rc.local
	fi
	chmod u+x /etc/rc.d/rc.local  #rc.local默认没有执行权限
	
	#local yum
	mkdir /tmp/yum.bak
	mv /etc/yum.repos.d/*.repo /tmp/yum.bak
	cat> /etc/yum.repos.d/local.repo <<EOF
[CentOS7]
name=local
baseurl=file:///mnt/
enabled=1
gpgcheck=0
EOF

	
	yum clean all 1>/dev/null 2>&1
	
	#firewall
	#停止NetworkManager
	systemctl stop NetworkManager
	systemctl disable NetworkManager
	
	iptables -F
	systemctl stop firewalld  2>/dev/null
	systemctl disable firewalld 2>/dev/null
	yum install -y iptables-services.x86_64  1>/dev/null 2>&1
	systemctl restart iptables.service
	
	#selinux	
	setenforce 0
	cat > /etc/selinux/config << EOF
SELINUX=disabled 
SELINUXTYPE=targeted 
EOF
	#stop postfix
	systemctl stop postfix.service 
	systemctl disable postfix.service
	
	yum -y install tree
	yum -y install net-tools
	yum -y install vim
	yum -y install ntsysv  #(快速启动关闭服务的简易图形界面)
	yum -y install psmisc
	yum -y install wget
	yum -y gcc gcc-c++ ncurses ncurses-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel
	yum -y install bash-completion
	
	#启动分辨率 sed依照vmlinuz-3特殊字样匹配 如果内核版本不再为3.10可能需要修改此项
	sed -i '/vmlinuz-3/{s/rhgb quiet/vga=817/}' /boot/grub2/grub.cfg
	#左侧用户显示路径更改为绝对路径
	sed -i '/&&[ ]PS1/{s/W/w/}'  /etc/bashrc
	

	#alibaba yum源
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	yum clean all && yum makecache
