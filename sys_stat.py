#!/usr/bin/python
# -*- coding: utf-8 -*-
#系统精简信息查询脚本 2019-12-13
#TODO：修改函数化
#需要python2\wmi\psutil环境,windows需要安装依赖包下载地址https://github.com/mhammond/pywin32/releases

import psutil, datetime
import platform
import os
#判定信息
class sys_stat:
	def system_jugde(): #判定系统，返回系统、CPU型号、启动时间
		global system, cpu_name, start_time
		if(platform.system()=='Windows'):
			import wmi
			system = 'Windows'
			cpuArr = wmi.WMI().Win32_Processor()
			for cpu in cpuArr:
				cpu_name = cpu.name
		if(platform.system()=='Linux'):
			system = 'Linux'
			cmd = "sed -n '/^model\ name/p' /proc/cpuinfo | cut -d':' -f2 | sort -u"
			output = os.popen(cmd)
			cpu_name = output.read()
		#sys_start_time
		start_time = datetime.datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S")

	def cpu_stat(): #CPU状态，返回核心、占用率
		global core, logic_core, cpu_percent
		core = str(psutil.cpu_count(logical=False))  #CPU物理核心
		logic_core = str(psutil.cpu_count())  #CPU逻辑数量
		if int(psutil.cpu_percent(interval=1)) > 90: #CPU使用超过90变红
			cpu_percent = '\033[1;31;40m' + str(psutil.cpu_percent(interval=1)) + '%' + '[警告]\033[40m'
		elif int(psutil.cpu_percent(interval=1)) > 60: #CPU使用超过60变黄
			cpu_percent = '\033[1;33;40m' + str(psutil.cpu_percent(interval=1)) + '%' + '[较高]\033[0m'
		else:
			cpu_percent = '\033[1;32;40m' + str(psutil.cpu_percent(interval=1)) + '%' + '[OK]\033[0m'

	def mem_stat():#内存状态，返回总内存，内存使用，使用率
		global mem_total, mem_used, swap_total, swap_used, mem_percent, swap_percent
		vir_mem = psutil.virtual_memory() #物理内存
		swap_mem = psutil.swap_memory() #swap内存
		###字节转化为GB
		mem_total_count = float(vir_mem.total)/1024000000
		mem_used_count = float(vir_mem.used)/1024000000
		swap_total_count = float(swap_mem.total)/1024000000
		swap_used_count = float(swap_mem.used)/1024000000
		#格式规范
		mem_total = str('%.2f' % mem_total_count ) + 'GB' #总内存
		mem_used = str('%.2f' % mem_used_count ) + 'GB' #使用内存
		swap_total = str('%.2f' % swap_total_count) + 'GB' #swap总大小
		swap_used = str('%.2f' % swap_used_count) + 'GB' #swap使用
		if int(vir_mem.percent) > 90: #内存使用超过90变红
			mem_percent =  '\033[1;31;40m' + str(vir_mem.percent) + '%' + '[警告]\033[0m'
		elif int(vir_mem.percent) > 60: #超过60变黄
			mem_percent = '\033[1;33;40m' + str(vir_mem.percent) + '%' + '[较高]\033[0m'
		else: #其他为绿色
			mem_percent = '\033[1;32;40m' + str(vir_mem.percent) + '%' + '[OK]\033[0m'

		if int(swap_mem.percent) > 90:
			swap_percent = '\033[1;31;40m' + str(swap_mem.percent) + '%' + '[警告]\033[0m'
		elif int(swap_mem.percent) > 60:
			swap_percent = '\033[1;33;40m' + str(swap_mem.percent) + '%' + '[较高]\033[0m'
		else:
			swap_percent = '\033[1;32;40m' + str(swap_mem.percent) + '%' + '[OK]\033[0m'#swap百分比

	def disk_stat(): #磁盘状态，返回，总磁盘，空闲，使用，使用率
		global disk_total, disk_free, disk_used, disk_percent
		disk = psutil.disk_usage('/')#磁盘使用情况
		#字节转化为GB
		disk_total_count = float(disk.total)/1024000000
		disk_free_count = float(disk.free)/1024000000
		disk_used_count = float(disk.used)/1024000000
		#格式规范
		disk_total = str('%.2f' % disk_total_count) + 'GB'
		disk_free = str('%.2f' % disk_free_count) + 'GB'
		disk_used = str('%.2f' % disk_used_count) + 'GB'
		if int(disk.percent) > 90:
			disk_percent = '\033[1;31;40m' + str(disk.percent) + '%' + '[警告]\033[0m'
		elif int(disk.percent) > 60:
			disk_percent = '\033[1;33;40m' + str(disk.percent) + '%' + '[较高]\033[0m'
		else:
			disk_percent = '\033[1;32;40m' + str(disk.percent) + '%' + '[OK]\033[0m'

#磁盘分区状态
#TODO:disk_partitions需要修改
	def disk_partitions(): #磁盘信息函数
		global disk_part
		global count_stamp
		disk_part = psutil.disk_partitions() #磁盘分区信息
		count_stamp = len(disk_part)
		# for idx in range(0,len(disk_part)):
		# 	disk_dir = {}
		# 	disk_dir['disk_part'] = {}
		# 	disk_dir['disk_part']['device']=disk_part[idx].device
		# 	disk_dir['disk_part']['mountpoint']=disk_part[idx].mountpoint

		#	print '盘符:', disk_part[idx].device,'挂载点:', disk_part[idx].mountpoint,'文件格式类型:',disk_part[idx].fstype,'其他信息:',disk_part[idx].opts
#输出状态函数
	def print_stat():
		print('机器启动的时间为：\033[1;35m%s\033[1;35;0m' % start_time)
		print('\033[0;32m=========================系统检查信息=========================\033[0m')
		print('当前操作系统为：\033[0;36m', system,'系统\033[0;36;0m')
		print('CPU型号：\033[0;36m', cpu_name,'\033[0;36;0m')
		print('\033[0;32m=========================硬件检查信息=========================\033[0m')
		print('CPU核心数:', core,' CPU线程数:', logic_core,' CPU使用率:', cpu_percent)
		print('内存大小:', mem_total,  '使用内存:',mem_used, '使用百分比:' , mem_percent)
		print('交换内存大小:', swap_total,'交换内存使用:', swap_used,'使用百分比:', swap_percent)
		print('磁盘总大小:',disk_total,'磁盘已使用:',disk_used,'磁盘空闲:',disk_free ,'使用百分比:',disk_percent)
		print('\033[0;32m========================磁盘分区检查信息=======================\033[0m')
		for idx in range(0,count_stamp):
			print('盘符:', disk_part[idx].device, '挂载点:', disk_part[idx].mountpoint, '文件格式类型:', disk_part[idx].fstype, '其他信息:', disk_part[idx].opts)

if __name__ == '__main__':
	sys_stat.system_jugde()
	sys_stat.cpu_stat()
	sys_stat.mem_stat()
	sys_stat.disk_stat()
	sys_stat.disk_partitions()
	sys_stat.print_stat()