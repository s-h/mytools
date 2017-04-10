#!/usr/bin/env python
# -*- coding: utf-8 -*- 
"""
zabbix监控中科同向日志脚本
示例日志:
    887 backupfile 完全 备份 完成 2017-03-27 14:50:58
示例jobFile
    backupfile*1|完全备份|2017-03-29 11:20:03

"""
import sys,re,json,time,copy,os
thisTime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
bakLogFile = "a.txt"
lastReadFile = "linefile.txt"
jobFile = "jobfile.txt"
debug = True
lastjob = {}
thisjob = {}

messages = {
        "状态未更新":0,
        "完成":1,
        "完成--有警告　":2,
        "错误":3,
        "严重错误":4,
        "取消":5,
        "验证差异":6,
        "未知":7,
        }
def printDebug(info):
    if debug:
        print info
def touchfile(filename):
    if not os.path.exists(filename):
        os.mknod(filename)

def touchfileEcho0(filename):
    if not os.path.exists(filename):
        f = open(filename,'w')
        f.write("0\n")
        f.close()

def readLastFile():
    touchfile(jobFile)  
    jobTxt = open(jobFile,'r')
    jobTxtlist = jobTxt.readlines()
    if len(jobTxtlist) == 0:
        pass
    else:
        for eachline in jobTxtlist:
            eachline = eachline.strip("\n")
            joblist = eachline.split("*")
            lastjob[joblist[0]] = joblist[1].split('|')

    jobTxt.close()
def writeLastFile(thisjob):
    jobTxt = open(jobFile,'w')
    jobTxt.truncate
    for key in thisjob:
        jobTxt.write(key + "*" + str(thisjob[key][0]) + "|" + thisjob[key][1] + "|" + thisjob[key][2])
        jobTxt.write("\n")
    jobTxt.close()

def writeReadLine(lastline):
    f = open(lastReadFile,'w')
    f.write(str(thisline))
    f.close()
   
def  getJobstatus(string):
    if string in messages:
        return messages[string]
    else:
        return 7 
    
def compareTime(onetime,twotime):
    oneStructTime = time.strptime(onetime,"%Y-%m-%d %H:%M:%S")
    twoStructTime = time.strptime(twotime,"%Y-%m-%d %H:%M:%S")
    return time.mktime(oneStructTime) - time.mktime(twoStructTime)
def init():
    logTxt = open(bakLogFile,'r').readlines()
    count = 1
    for eachline in logTxt:
        if count <= lastline:
            printDebug("跳过行" + str(count))
            count += 1
            continue
        else:
            bakStatusLine = eachline.split(" ")
            jobname = bakStatusLine[1]
            jobStatus = bakStatusLine[4]
            jobStatuscode = getJobstatus(jobStatus)
            jobmessage = bakStatusLine[2] + bakStatusLine[3]
            messTime = bakStatusLine[-2] + ' ' + bakStatusLine[-1].strip("\n")
            messages = [jobStatuscode,jobmessage,messTime]
            if jobStatus == "完成" and (jobname in thisjob):
                if [jobname][0] != "完成" and compareTime(messTime,thisjob[jobname][2]) < 600:    #忽略600s内完成状态覆盖
                    continue
            thisjob[jobname] = messages
    writeReadLine(thisline) #正式使用打开
def discovery():
    print "{"
    print '     "data":['
    for key in thisjob.keys():
        jobname = key.strip("\n")
        print '         {"{#JOBNAME}":"'+jobname+'"},'
    print '         {"{#END}":"NULL"}'
    print '         ]'
    print '}'

touchfileEcho0(lastReadFile)
lastline = int(open(lastReadFile,'r').readline())
thisline = len(open(bakLogFile,'r').readlines())


if sys.argv[1] == "discovery":
    readLastFile()
    thisjob = copy.deepcopy(lastjob)
    init()
    discovery()
    writeLastFile(thisjob)
elif sys.argv[1] == "getstatus":
    readLastFile()
    thisjob = copy.deepcopy(lastjob)
    init()
    jobname = sys.argv[2]
    if jobname in thisjob:                         #item存在
        if int(thisjob[jobname][0]) != 1:                #状态异常直接返回异常值
            printDebug("go 1")
            print thisjob[jobname][0]
        else:                                      #状态为完成
            if compareTime(thisTime,thisjob[jobname][2].strip("\n")) < 300: # 如果最"完成"后更新未超过指定300s,返回1
                printDebug("go 3")
                print thisjob[jobname][0]      #1
            else:
                printDebug("go 4")
                print 0                        #状态未更新

    else:
        print "no this item"
    writeLastFile(thisjob)

elif sys.argv[1] == "test":
    readLastFile()
