#!/usr/bin/env bash
# mysql备份脚本，使用mysqldump，在不适用xtrabackup时使用
# ver 20201113
#https://github.com/s-h/mytools/shell/mybak.sh
#docker 运行 docker run --rm --name backuptmpdocker -v /backup:/backup mysql:5.7.28 /backup/mysqldumpAndFile.sh >> /tmp/log 2>&1 
set -x 
# 日志文件
logfile="/backup/mybak.log"
today=$(date +%Y%m%d)
# 备份存放目录
backupdir="/backup/data/$today"
# 临时文件
tmpdir="/backup/tmp/mybaktmp$today"
# 备份文件或目录,如不需备份可为空
backupfile=(
file
/dir/
)
# mysqladmin命令指向
mysqladmin="mysqladmin"
# mysqldump命令指向
mysqldump="mysqldump"
# 数据库用户
mysqlUser="mysqluser"
# 数据库密码
mysqlPwd="pasword"
# 数据地址
host="127.0.0.1"
# 备份数据库
mysqlDatabase=(
databasename
)
# 是否备份全部数据库(mysqldump --all-databases参数)，确保用户有相应权限
allDatabase=false
# 数据库是否启用binlog
# 开启binlog将启用mysqldump的--master-data --single-transaction参数
isBinlog=true

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
    # 使用msyqladmin测试数据库可连接性
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
    if [ "isBinlog" = "true" ];then
        extendArgs=" --master-data --single-transaction "
    else
        extendArgs=""
    fi
    if [ "$mysqlStatus"x = "ok"x ] && [ "$allDatabase"x = "false"x ];then
    # 单库备份
        for database in ${mysqlDatabase[@]};do
            echo "$database 开始备份"
            # --master-data --single-transaction
            # pass
            # --max_allowed_packet --net_buffer_length
            # pass
            $mysqldump -h$host -u$mysqlUser -p$mysqlPwd $database \
                $extendArgs \
                -e --max_allowed_packet=$mysqlMAP --net_buffer_length=$mysqlNBL  \
                > $backupdir/mysql-$database-$today.sql 2>>$logfile && backupStatus="ok" || backupStatus="bad"
            if [ $backupStatus = "ok" ];then
                bzip2 $backupdir/mysql-$database-$today.sql
	            logger "$database backup ok" 
            else
                logger "$database backup bad"
            fi
        done
    elif [ "$mysqlStatus"x = "ok"x ] && [ "$allDatabase"x = "true"x ];then
    # 所有数据库备份
        $mysqldump -h$host -u$mysqlUser -p$mysqlPwd --all-databases \
            $extendArgs \
            -e --max_allowed_packet=$mysqlMAP --net_buffer_length=$mysqlNBL  \
            > $backupdir/mysql-alldatabase-$today.sql 2>>$logfile && backupStatus="ok" || backupStatus="bad"
        if [ $backupStatus = "ok" ];then
            bzip2 $backupdir/mysql-alldatabase-$today.sql
            logger "$database backup ok" 
        else
            logger "$database backup bad"
        fi
    else
    # 数据库状态监测失败
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