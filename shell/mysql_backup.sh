#!/bin/bash
LogFile=/backup/backup.log
BakDir=/backup

if [ -d $BakDir ]
then
    cd $BakDir
    touch $LogFile
else
    mkdir -p $BakDir
    cd $BakDir
    touch $LogFile
fi
echo "">>$LogFile
echo "==================">>$LogFile
echo "`date +%Y%m%d`">>$LogFile
my_db="opts2"
guidang="/opts2Accessories/"
mysqluser="root"
userpass="icpdb"


if mysqldump -u $mysqluser --password=$userpass -h localhost --opt $my_db > $my_db.`date +%Y%m%d`.sql 2>&1
then
    echo " backup $my_db success" >> $LogFile
else
    echo " backup $my_db error" >> $LogFile
    exit 1
fi

if tar czpf beian.`date +%Y%m%d`.tar.gz $guidang $my_db.`date +%Y%m%d`.sql >/dev/null 2>&1
then
    echo " backup beian success" >> $LogFile
    rm -f $my_db.`date +%Y%m%d`.sql
else
    echo " backup beian error" >> $LogFile
    exit 1
fi

scp -P 2200 /backup/beian.`date +%Y%m%d`.tar.gz scp@175.188.160.60:/home/www/backup/beian
find /backup/*.gz -mtime +40 -exec rm -rf {} \;



