#!/bin/bash
#作者：LLM(Timothy Luo)
#修改端口模块脚本

#####修改端口模块#####
modify(){
stty erase '^H'  #####read语句前转化退格符
while true
do
read -p "请输入需要设置的nginx模块端口号(默认为80，输入数字)：" portnum_nginx
if echo ${portnum_nginx} | grep -q '[^0-9]'
then echo "请输入数字"
	continue
else break
fi
done

while true
do
read -p "请输入需要设置的unicorn模块端口号(默认为8080，输入数字)：" portnum_unicorn
if echo ${portnum_unicorn} | grep -q '[^0-9]'
then echo "请输入数字"
	continue
else break
fi
done

sed -i 's/nginx\['\''listen_port'\''\].*/nginx\['\''listen_port'\''\] = '$portnum_nginx' /g' /etc/gitlab/gitlab.rb  ####修改gitlab.rb的nginx监听端口项
if [ $? -eq 0 ]
then echo "nginx端口修改成功！"
fi
sed -i 's/unicorn\['\''port'\''\].*/unicorn\['\''port'\''\] = '$portnum_unicorn' /g' /etc/gitlab/gitlab.rb   ####修改gitlab.rb的unicorn监听端口项
if [ $? -eq 0 ]
then echo "unicorn端口修改成功！"
fi
}

sleep 1
modify
