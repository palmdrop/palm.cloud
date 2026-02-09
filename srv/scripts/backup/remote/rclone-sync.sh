#!/bin/bash

set -eou pipefail

source /srv/server.env

echo "====== Syncing repo to remote ====== "  

rclone sync \
    $BORG_REPO \
    $RCLONE_NEXTCLOUD_REMOTE:$RCLONE_NEXTCLOUD_REMOTE_BUCKET

echo "====== Done syncing backups to remote ====== "  
