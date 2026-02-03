#!/bin/bash

source ./.env

CRON_JOB="0 2 * * * /home/palmdrop/server/scripts/backup/borg-backup.sh >> $NEXTCLOUD_BACKUP_LOG_FILE 2>&1"

echo "Creating cron job..."
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Creating log file..."
sudo touch $NEXTCLOUD_BACKUP_LOG_FILE
sudo chown $USER:$USER $NEXTCLOUD_BACKUP_LOG_FILE



