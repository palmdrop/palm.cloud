#!/bin/bash

set -eou pipefail

source /srv/server.env

export BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"

BACKUP_NAME="${1:-}"

if [ ! -z "$BACKUP_NAME" ]; then
    borg mount $BORG_REPO::$BACKUP_NAME $BORG_MOUNT_DIR
else 
    borg mount $BORG_REPO $BORG_MOUNT_DIR
fi

