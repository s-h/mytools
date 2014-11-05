#!/usr/bin/env python
# -*- coding: utf-8 -*- 
#import getpass
import telnetlib
import os
import time
import shutil

date = time.strftime('%Y-%m-%d',time.localtime(time.time()))
password = "passwd1"
password2 = "passwd2"
usrpath = "/home/backup/"
wwwpath = "/home/www/backup/"
def mkdirs(path):
        isExists = os.path.exists(path)
        if not isExists:
                #print "bucunzai"
                os.makedirs(path)
        else:
                print "cunzai"
mkdirs(wwwpath + "OLT/" + date)
#---##----##----##----##----##----##----##----##----##----##----##----##---##--
# 格林olt地址
olt_gw_hosts= {
	"10.40.4.3":["user",password,"xx6900","6900"],
	"10.40.4.4":["user1",password,"xx6700","6700"],
	}	
olt_rs_hosts= {
	"10.40.9.2":["user",password,"xx5800","5800"],
	"10.40.9.8":["user1",password,"xx5800","5800"],
	}	
def gwolt_init(i):
	#print olt_gw_hosts[i][0]
	print i
	print ""
	filename = olt_gw_hosts[i][0] + "_" + date
	savename = olt_gw_hosts[i][2] + "_" + i + ".txt"
	tn = telnetlib.Telnet(i)
	tn.read_until(b"Login:")
	tn.write( olt_gw_hosts[i][0] + b"\n")
	tn.read_until(b"Password:")
	tn.write(olt_gw_hosts[i][1] + b"\n")
	tn.write("ena\n")
	tn.read_until(b"Password:")
	tn.write( olt_gw_hosts[i][1] + b"\n")
	tn.write("upload ftp config ftpIP ftpuser ftppassowrd " + filename + "\n")
	tn.write("exit\n")
	tn.write("exit\n")
	print(tn.read_all())
	shutil.move(usrpath + filename ,wwwpath + "OLT/" + date + "/" + savename)
	
	
def gwolt_backup(olt_gw_hosts):
	#print "test"
	for i in olt_gw_hosts.keys():
		try:
			gwolt_init(i)
		except:
			continue

def rsolt_init(i):
	filename = olt_rs_hosts[i][0] + "_" + date
	savename = olt_rs_hosts[i][2] + "_" + i + ".txt"
	print i
	print ""
	print olt_rs_hosts[i][2]
	tn = telnetlib.Telnet(i)
	tn.read_until(b"Login:")
	tn.write(olt_rs_hosts[i][0] + b"\n")
	tn.read_until(b"Password:")
	tn.write(olt_rs_hosts[i][1] + b"\n")
	tn.write("ena\n")
	tn.read_until(b"Password:")
	tn.write(password + b"\n")
	tn.write("upload startup-config ftp ftpIP ftpuser ftppassword " + filename + "\n")
	tn.write("exit\n")
	print(tn.read_all())
	shutil.move(usrpath + filename ,wwwpath + "OLT/" + date + "/" + savename)

def rsolt_backup(olt_rs_hosts):
        for i in olt_rs_hosts.keys():
		print i
                try:
                        rsolt_init(i)
                except:
                        continue
def xieru(logpath,text):
	output = open( logpath,'a')
	output.write(text + '\n')
	output.close
def file_check(olt_hosts,olt_changjia):
	success = 0
	faile = 0
	logpath = wwwpath + "OLT/" + date + "/backup.log"
	text = "<DIV>********" + olt_changjia + "*********</DIV>"
	xieru(logpath,text)
	for i in olt_hosts:
		savename = olt_hosts[i][2] + "_" + i + ".txt"	
		path = wwwpath + "OLT/" + date + "/" + savename 	
		isExists = os.path.exists(path)
		if not isExists:
			faile += 1
			text ="<DIV><FONT color=#ff0000>" + olt_hosts[i][2]+ "备份失败!" + "</FONT></DIV>"
			xieru(logpath,text)
		else:
			success += 1
			text ="<DIV>" +  olt_hosts[i][2] + " backup is ok" +"</DIV>"
			xieru(logpath,text)
	text = "<DIV>>>>>>>>>>>>>>>>>>>>>> </DIV>" + '\n' + "<DIV>共" + str(success) + "备份成功, " + "共" + str(faile) + "备份失败</DIV>"
	xieru(logpath,text)
#---##----##----##----##----##----##----##----##----##----##----##----##---##--
#启用备份
rsolt_backup(olt_rs_hosts)
gwolt_backup(olt_gw_hosts)
file_check(olt_gw_hosts,"格林韦迪")
file_check(olt_rs_hosts,"瑞斯康达")
os.system("/opt/mail.sh")
