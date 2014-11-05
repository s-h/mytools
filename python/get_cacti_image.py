#!/usr/bin/env python
# -*- coding: utf-8 -*
'''
这是一个自动抓去cacti图片的脚本
ver 2014-11-5
'''
import os
import time
year = time.strftime('%Y',time.localtime(time.time()))
month = time.strftime('%m',time.localtime(time.time()))
day = time.strftime('%d',time.localtime(time.time()))
date = year + "-" + month + "-" + day
wwwpath = "/home/www/backup/image" + "/" + year + "/" + month + "/" + day + "/"
def mkdirs(wwwpath):
        isExists = os.path.exists(wwwpath)
        if not isExists:
                print "mkdir wwwpath"
                os.makedirs(wwwpath)
        else:
                print "dir exist"
mkdirs(wwwpath)

url = {
	"230":"用户流量总计",
	"1428":"用户流量总计-me60-1",
	"2039":"用户流量总计-me60x8-1",
	"1858":"BGP",
	}
os.system("wget --load-cookies cookies.txt --save-cookies tmp/cookies.txt --keep-session-cookies -O tmp/login.html --post-data \"action=login&login_password=password&login_username=admin\" http://ip/index.php")
for id in url.keys():
	os.system("wget --load-cookies tmp/cookies.txt --save-cookies tmp/cookies.txt --keep-session-cookies -O " + wwwpath + url[id] + ".png \"http://ip/graph_image.php?action=view&local_graph_id=" + id + "&rra_id=1\"")
