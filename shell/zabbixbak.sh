#!/usr/bin/env bash
#zabbix备份脚本
#https://github.com/s-h/mytools/shell/zabbixbak.sh
logfile="/opt/backup/zabbixbak.log"
pidfile="/opt/backup/zabbixbak.pid"
today=$(date +%Y%m%d)

backupdir="/opt/backup/$today"
tmpdir="/tmp/zabbixbaktmp$today"
backupfile=(
/etc/zabbix/zabbix_server.conf
/etc/zabbix/zabbix_agentd.conf
/etc/zabbix/zabbix_agentd.d/
/etc/grafana/grafana.ini
/etc/my.cnf
/etc/php.ini
/etc/zabbix/scripts/
/usr/lib/zabbix/alertscripts
/etc/orabbix/conf/
)

mysqlUser="root"
mysqlPwd="youpassword"
mysqlDatabase=(
zabbix
grafana
)

function thisTime() {
    echo $(date +%Y%m%d-%H%M%S)
}

function pid() {
    if [ $1 == "start" ];then
        if [ -e $pidfile ];then
            echo "$pidfile 已存在"
            exit 1
        else
            ps -ef |grep $0 |grep -v grep| awk '{print $2}' > $pidfile
        fi
    elif [ $1 == "stop" ];then
        rm -f $pidfile
    fi
}

function logger() {
    time=$(thisTime)
    echo "[$time] $1" >> $logfile
}
function mktarget() {
    target=$(dirname $1)
    if [ ! -d $tmpdir$target ];then 
        mkdir -p $tmpdir$target      #创建目标目录
    fi
}
function cpbakfile() {
    for filename in ${backupfile[@]};do
        if [ -e $filename ];then
            mktarget $filename
            cp -ap $filename $tmpdir$filename
            logger "$filename 文件已备份"

        elif [ -d $filename ];then
            mktarget $filename
            cp -ap $filename* $tmpdir$filename
            logger "$filename 目录已备份"

        else
            logger "$filename 文件或目录不存在"
        fi
    done

}

function tarfile() {
    cd $tmpdir && cd ..
    tar czpf zabbix_file_bak.$today.tar.gz zabbixbaktmp$today
    rm -rf $tmpdir
    mv zabbix_file_bak.$today.tar.gz $backupdir
}
function getMysqlValue () {
    mysqlMAP=$(mysql -u$mysqlUser -p$mysqlPwd -e "show variables like 'max_allowed_packet';" 2>/dev/null |grep max_allowed_packet | awk {'print $2'})
    mysqlNBL=$(mysql -u$mysqlUser -p$mysqlPwd -e "show variables like 'net_buffer_length';" 2>/dev/null |grep net_buffer_length | awk {'print $2'})
    if [ "$mysqlMAP"x = "x" ];then
        logger "mysql max_allowed_packet is empty"
    else
        logger "mysql max_allowed_packet is $mysqlMAP"
    fi

    if [ "$mysqlNBL"x = "x" ];then
        logger "mysql net_buffer_length is empty"
    else
        logger "mysql net_buffer_length is $mysqlNBL"
    fi
}
function mysqlping() {
    mysqlPingCmd=$(mysqladmin -u$mysqlUser -p$mysqlPwd ping 2>/dev/null)
    mysqlOk="mysqld is alive"
    if [ "$mysqlPingCmd"x != "$mysqlOk"x ];then
        mysqlStatus="failed"
    else
        mysqlStatus="ok"
    fi
}
function bakmysql() {
    mysqlping
    if [ "$mysqlStatus"x = "ok"x ];then
        for database in ${mysqlDatabase[@]};do
                mysqldump -u$mysqlUser -p$mysqlPwd $database -e --max_allowed_packet=$mysqlMAP --net_buffer_length=$mysqlNBL  | bzip2 -9 > $backupdir/mysql-$database-$today.bz2 2>/dev/null
                logger "mysql $database backup is ok"
       done
   else
       logger "msyql backup failed!"
   fi
}

mkdir $backupdir
mkdir $tmpdir

pid start
logger "--------$0开始执行------"
cpbakfile
tarfile
getMysqlValue
bakmysql
pid stop
