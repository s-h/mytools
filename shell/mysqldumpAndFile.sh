#!/usr/bin/env bash
# mysql备份脚本，使用mysqldump，在不适用xtrabackup时使用
# ver 20201113
#https://github.com/s-h/mytools/shell/mybak.sh
logfile="/backup/mybak.log"
#pidfile="/opt/backup/mybak.pid"
today=$(date +%Y%m%d)
backupdir="/backup/data/$today"
tmpdir="/backup/tmp/mybaktmp$today"
# 备份文件
backupfile=(
file
/dir/
)
#mysqladmin命令指向
mysqladmin="mysqladmin"
#mysqldump命令指向
mysqldump="mysqldump"
mysqlUser="mysqluser"
mysqlPwd="pasword"
host="127.0.0.1"
#备份数据库
mysqlDatabase=(
databasename
)

function thisTime() {
    echo $(date +%Y%m%d-%H%M%S)
}
function logger() {
    time=$(thisTime)
    echo "[$time] $1" >> $logfile
}
function mktarget() {
    target=$(dirname $1)
    if [ ! -d $tmpdir$target ];then 
        #创建目标目录
        mkdir -p $tmpdir$target  
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
    tar czpf my_file_bak.$today.tar.gz mybaktmp$today
    rm -rf $tmpdir
    mv my_file_bak.$today.tar.gz $backupdir
}
function getMysqlValue () {
    mysqlMAP=$(mysql -h$host -u$mysqlUser -p$mysqlPwd -e "show variables like 'max_allowed_packet';" 2>/dev/null |grep max_allowed_packet | awk {'print $2'})
    mysqlNBL=$(mysql -h$host -u$mysqlUser -p$mysqlPwd -e "show variables like 'net_buffer_length';" 2>/dev/null |grep net_buffer_length | awk {'print $2'})
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
    mysqlPingCmd=$($mysqladmin -h$host -u$mysqlUser -p$mysqlPwd ping 2>>$logfile)
    mysqlOk="mysqld is alive"
    if [ "$mysqlPingCmd"x != "$mysqlOk"x ];then
        mysqlStatus="bad"
    else
        mysqlStatus="ok"
    fi
}
function bakmysql() {
    mysqlping
    if [ "$mysqlStatus"x = "ok"x ];then
        for database in ${mysqlDatabase[@]};do
            echo "$database 开始备份"
            # --master-data --single-transaction
            # pass
            # --max_allowed_packet --net_buffer_length
            # pass
            $mysqldump -h$host -u$mysqlUser -p$mysqlPwd $database \
                --master-data --single-transaction \
                -e --max_allowed_packet=$mysqlMAP --net_buffer_length=$mysqlNBL  \
                > $backupdir/mysql-$database-$today.sql 2>>$logfile && backupStatus="ok" || backupStatus="bad"
            if [ $backupStatus = "ok" ];then
                bzip2 $backupdir/mysql-$database-$today.sql
	            logger "$database backup ok" 
            else
                logger "$database backup bad"
            fi
        done
   else
        logger "msyql status is bad!"
   fi
}

mkdir -p $backupdir
mkdir -p $tmpdir

logger "--------$0开始执行------"
cpbakfile
tarfile
getMysqlValue
bakmysql