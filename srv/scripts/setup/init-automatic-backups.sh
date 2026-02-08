#!/bin/bash

cd /srv/

source ./server.env

# Local backups
LOCAL_BACKUPS_JOB="0 2 * * * /srv/scripts/backup/borg-backup.sh >> $NEXTCLOUD_BACKUP_LOG_FILE 2>&1"
REMOTE_BACKUPS_JOB="0 3 * * * /srv/scripts/backup/remote/rclone-sync.sh >> $NEXTCLOUD_REMOTE_BACKUP_LOG_FILE 2>&1"

echo "Creating cron jobs..."
(crontab -l 2>/dev/null; echo "$LOCAL_BACKUPS_JOB") | crontab -
(crontab -l 2>/dev/null; echo "$REMOTE_BACKUPS_JOB") | crontab -

echo "Creating log files..."
sudo touch $NEXTCLOUD_BACKUP_LOG_FILE
sudo chown $USER:$USER $NEXTCLOUD_BACKUP_LOG_FILE

sudo touch $NEXTCLOUD_REMOTE_BACKUP_LOG_FILE
sudo chown $USER:$USER $NEXTCLOUD_REMOTE_BACKUP_LOG_FILE



