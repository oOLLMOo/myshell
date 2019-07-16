#!/bin/bash
#Date 2019-04-11
#Author: Created by llm
#Function: MySQL5.7编译安装、附带配置功能、启动mysql并给出初始密码
#Version: 1.2
#注意：脚本执行目录下需要有boost和mysql的源码包

#判断当前目录是否有boost和mysql特定包名函数
check(){
ls ./boost_1_59_0.tar.gz >/dev/null
if [ $? -ne 0 ]
	then echo "未发现boost_1_59_0.tar.gz"
	exit
fi

ls ./mysql-5.7.19.tar.gz>/dev/null
if [ $? -ne 0 ]
	then echo "未发现mysql-5.7.19.tar.gz"
	exit
fi

}

check
yum -y install cmake
yum -y install gcc-c++.x86_64 
yum -y install gcc-gfortran.x86_64
yum -y install gcc-gnat.x86_64
yum -y install gcc-objc.x86_64
yum -y install gcc-objc++.x86_64
yum -y install ncurses-devel.x86_64

tar xvf boost_1_59_0.tar.gz
mv boost_1_59_0 /usr/local/boost

tar xvf mysql-5.7.19.tar.gz -C /usr/local/src/
cd /usr/local/src/mysql-5.7.19/

groupadd -g 27 mysql
useradd -u 27 -g mysql -M -s /sbin/nologin mysql

mkdir -p /data/mysql
chown mysql:mysql /data/mysql

cmake  -DCMAKE_INSTALL_PREFIX=/usr/local/mysql57 -DMYSQL_DATADIR=/data/mysql  -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock  -DMYSQL_USER=mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost -DWITH_INNODB_MEMCACHED=ON
make
make install

yum remove mariadb
chown -R mysql:mysql /usr/local/mysql57

cat >/etc/my.cnf<<EOF
[client]
port=3306
socket=/data/mysql/mysql.sock

[mysqld]
character-set-server=utf8 
collation-server=utf8_general_ci

skip-name-resolve
user=mysql
port=3306
basedir=/usr/local/mysql57
datadir=/data/mysql
tmpdir=/tmp
socket=/data/mysql/mysql.sock

log-error=/data/mysql/mysqld.log
pid-file=/data/mysql/mysqld.pid 

EOF

PATH=$PATH:/usr/local/mysql57/bin
echo "PATH=$PATH:/usr/local/mysql57/bin" >>/etc/profile

/usr/local/mysql57/bin/mysqld  --defaults-file=/etc/my.cnf   --initialize  --user=mysql 

/usr/local/mysql57/support-files/mysql.server   start #启动mysql

echo "mysql初始密码：`cat /data/mysql/mysqld.log | grep password | awk '{print $NF}'`"
