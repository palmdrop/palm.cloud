#!/bin/bash

set -eou pipefail

source /srv/server.env

BORG_KEY="${SECRETS_DIR}/backup/borg-repo-key.txt"

sudo mkdir -p "$BORG_REPO"
sudo chown $USER:$USER "$BORG_REPO"

borg init --encryption=repokey "$BORG_REPO"

borg key export "$BORG_REPO" "$BORG_KEY" 
chmod 600 "$BORG_KEY" 

echo "BORG is setup! Remember to create a '${BORG_PASSPHRASE_FILE}' file with the passphrase, for automatic backups"

echo: "Also: add the following line to the crontab:"
# TODO: Do this automatically?
echo: "0 2 * * * /srv/scripts/backup/borg-backup.sh >> /var/log/nextcloud-backup.log 2>&1"
