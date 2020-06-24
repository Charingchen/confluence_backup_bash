# Confluence Backup Bash Script
This scripts is used to back up Confluence self host server production on a Linux machine.
The goal is to zip the entire home directory of confluence and export the MySQL database that connected to the confluence server.

## Zip Confluence home directory
Uses tar command:
```bash
BACKUPTIME=`date +%b-%d-%y` #get the current date
HOME_BACKUP=/home/confluence_backup/backup-$BACKUPTIME.tar.gz #create a backup file using the current date in it's name
SOURCEFOLDER=/var/atlassian/application-data #the folder that contains the files that we want to backup

tar -cpzf $HOME_BACKUP $SOURCEFOLDER #create the backup
```

## Backup MySQL using scripts
MySQL code is referece from https://conetix.com.au/support/scripted-mysql-database-backups/. I am using those functions and only run the function differently. 
Note mysqldump need input user and its password to perform the dump. Here I harded code the password in the script. You also need to flag the max allowed packet to 512 Mb because the confluence database is quite big
```
mysqldump -u [user] -p[userpwd] -B ${DB}  --add-drop-database --add-drop-table --max_allowed_packet=512M >> ${DBFILE}
```
Setting up the log file for mysqldump:
```bash
FILE_DATE=`date '+%Y-%m-%d'`
LF_DIR=/home/confluence_backup/db-backups/logs/db-backup
LF=$LF_DIR/db-backup-$FILE_DATE.log
mkdir -p $LF_DIR
chmod 777 $LF_DIR
touch $LF
chmod 664 $LF

DBLIST=/tmp/dblist-$FILE_DATE.list
```
Instead of dumping all the databases, I only need the one connect to the confluence.

```bash
line="[confluence database name]"
echo "Backuping up Database: $line" >>$LF
H="localhost"
DB=$line
DoBackup
echo "All backups Completed" >> $LF
```
## File Transfer
To tranfer the file to your back linux machine, use ssh key gen and tranfer using scp
```bash
scp $HOME_BACKUP user@remotebackhost:/home/backup
echo "confluence zip sending Done" >>$LF
scp $DBFILE.gz user@remotebackhost:/home/backup
echo "Database backup sending Done">>$LF
```

## Automate this script to run periodly
Use crontab -e to open up crontab script and run it every Saturday at 8 pm
```
0 20 * * 6 /home/confluence_backup.sh
```