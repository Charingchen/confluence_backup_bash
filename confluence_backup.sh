#!/bin/bash

#################################################
### Backing up Confluence home directory

BACKUPTIME=`date +%b-%d-%y` #get the current date
HOME_BACKUP=/home/confluence_backup/backup-$BACKUPTIME.tar.gz #create a backup file using the current date in it's name
SOURCEFOLDER=/var/atlassian/application-data #the folder that contains the files that we want to backup


#################################################
# Backing up Confluence Database
# use mysqldump to Dump DB and compress it on the fly to a mounted partition

BACKUP_DIR="/home/confluence_backup/db-backups"
mkdir -p $BACKUP_DIR
chmod 777 $BACKUP_DIR
#
#
SERIAL="`date +%b-%d-%y`"

#=====================================
# Log Functions
#
function LogStart
{
echo "====== Log Start =========" >> $LF
echo "Time: `date`" >> $LF
echo " " >> $LF
}
function LogEnd
{
echo " " >> $LF
echo "Time: `date`" >> $LF
echo "====== Log End   =========" >> $LF
}

#=====================================
#
#
function DoBackup
{
echo "Calling DoBackup()" >> $LF

DBFILE=$BACKUP_DIR/db-$DB-$SERIAL.sql
echo "Host [$H]" >> $LF
echo "DB File [$DBFILE]" >> $LF
if [ -a  $DBFILE ]
then
mv $DBFILE $DBFILE.`date '+%M%S'`
fi
echo "Dumping ${DB}" >> $LF
mysqldump -u [user] -p[userpwd] -B ${DB}  --add-drop-database --add-drop-table --max_allowed_packet=512M >> ${DBFILE}
echo "Zipping up file!" >> $LF
gzip ${DBFILE}
echo "Done!" >> $LF
}

FILE_DATE=`date '+%Y-%m-%d'`
LF_DIR=/home/confluence_backup/db-backups/logs/db-backup
LF=$LF_DIR/db-backup-$FILE_DATE.log
mkdir -p $LF_DIR
chmod 777 $LF_DIR
touch $LF
chmod 664 $LF

DBLIST=/tmp/dblist-$FILE_DATE.list

LogStart
#=====================================
#
#                     MAIN Code Start
echo "Start zipping conflunece home directory" >> $LF
tar -cpzf $HOME_BACKUP $SOURCEFOLDER #create the backup
echo "Done Zipping, saved at $SOURCEFOLDER" >>$LF


line="[confluence database name]"
echo "Backuping up Database: $line" >>$LF
H="localhost"
DB=$line
DoBackup
echo "All backups Completed" >> $LF


############################################
### File transfer code
# connect via scp
scp $HOME_BACKUP user@remotebackhost:/home/backup
echo "confluence zip sending Done" >>$LF
scp $DBFILE.gz user@remotebackhost:/home/backup
echo "Database backup sending Done">>$LF
LogEnd
