#!/bin/bash

set -eou pipefail

source /srv/server.env

export const TMP_DIR="/tmp/borg-remote-restore"
export const BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"

echo "Pulling from R2 storage..."

rclone -vP sync \
    $RCLONE_NEXTCLOUD_REMOTE:$RCLONE_NEXTCLOUD_REMOTE_BUCKET \
    $TMP_DIR

echo "Done pulling. Borg repo is temporarily stored at $TMP_DIR"

echo "Listing available backups..."

borg list $TMP_DIR

echo "Mounting borg repo..."
borg mount $TMP_DIR $BORG_MOUNT_DIR

echo "Repo mounted at $BORG_MOUNT_DIR"

 


