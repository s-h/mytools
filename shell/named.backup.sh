#!/bin/bash
#==================
# This is named server backup sh
# 
#==================
PATH=/bin:/usr/bin:/sbin:/usr/sbin; export PATH
backdir=/root/backdir
named=$backdir/named
day=`date --date=yesterday +%Y%m%d`
backupserverip=
username=
passwd=
cp -a /var/named/chroot/etc     $named/chroot
cp -a /var/named/chroot/var/named/*.rev $named/chroot/var
cp -a /var/named/chroot/var/named/*.cn  $named/chroot/var
cp -a /var/named/chroot/var/named/*.com $named/chroot/var
cp -a /var/named/chroot/var/named/*.net $named/chroot/var
cp -a /var/named/chroot/var/named/*.zone $named/chroot/var
cp -a /var/named/chroot/var/named/*.ca  $named/chroot/var
cp -a /var/named/chroot/var/named/jiechi.common $named/chroot/var
cp -a /var/named/chroot/var/named/*.local $named/chroot/var
cd $backdir/named
tar -zpcf named254."$day".tar.gz * 2>> /dev/null
mv named254."$day".tar.gz $backdir
sync
rm -rf /root/backdir/named/chroot/etc/*
rm -rf /root/backdir/named/chroot/var/*
sync
#Remove old backups
find $backdir/*.gz -mtime +2 -exec rm -fr {} \; > /dev/null 2>&1
#################################ftp
cd $backdir
ftp -n $backupserverip <<EOC
user    $username      $passwd
binary
cd backup/named/254
put named254."$day".tar.gz
bye
EOC
sync;sync

