#!/usr/bin/env python
# -*- coding: utf-8 -*
# ver jianghao 2016-12-2
# 用于lvs检测realserver状态
import sys,re,commands
import threading,Queue
error_number = 4  #解析失败个数,当达到error_number及返回error_number个数,否则返回0
q = Queue.Queue()
success_number = 0
dns_server = sys.argv[1]
domain_list = [
"www.baidu.com",
"www.qiyi.com",
"www.sina.com.cn",
"www.amazon.cn",
"www.youku.com",
"www.qq.com",
"www.xiaomi.com",
"www.jd.com",
"www.taobao.com",
]
dig_command = "/usr/bin/dig +short"
def dig_domain(domain,dns_server):
    (status,output) = commands.getstatusoutput(dig_command + ' ' + domain + ' @' + dns_server)
    #q.put(status)
    q.put(output) #返回解析结果
    
def check_result_number(result_list):
    result_error_number = 0
    for i in result_list:
        if not re.findall('(\d{1,3}\.){3}\d{1,3}',i): #如果解析结果里没有ip地址,判定解析失败
            result_error_number += 1
    print "result_error_number is " + str(result_error_number)
    if result_error_number >= error_number:
        sys.exit(result_error_number)
    else:
        sys.exit
def main():
    threads = []
    result = []
    nloops = range(len(domain_list))
    for i in nloops:
        t = threading.Thread(target=dig_domain,args=(domain_list[i],dns_server))
        threads.append(t)

    for i in nloops:
        threads[i].start()

    for i in nloops:
        threads[i].join()

    while not q.empty():
        result.append(q.get())

    #for item in result:
        #print item
        #print ''
    check_result_number(result)

if  __name__ == '__main__':
    main()
