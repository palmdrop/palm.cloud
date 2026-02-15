#!/bin/bash

set -eou pipefail

source /srv/server.env

BORG_KEY="${SECRETS_DIR}/borg/repo-key.txt"
BORG_MEDIA_KEY="${SECRETS_DIR}/borg/media-repo-key.txt"

# MAIN REPO
sudo mkdir -p "$BORG_REPO"
sudo chown $USER:$USER "$BORG_REPO"

borg init --encryption=repokey "$BORG_REPO"

borg key export "$BORG_REPO" "$BORG_KEY" 
chmod 600 "$BORG_KEY" 

# MEDIA REPO
sudo mkdir -p "$BORG_MEDIA_REPO"
sudo chown $USER:$USER "$BORG_REPO"

borg init --encryption=repokey "$BORG_MEDIA_REPO"

borg key export "$BORG_MEDIA_REPO" "$BORG_MEDIA_KEY"
chmod 600 "$BORG_KEY" 

# Notes
echo "BORG is setup! Remember to create a '${BORG_PASSPHRASE_FILE}' file with the passphrase, for automatic backups"

echo: "Also: add the following line to the crontab:"
# TODO: Do this automatically?
echo: "0 2 * * * /srv/scripts/backup/borg-backup.sh >> /var/log/nextcloud-backup.log 2>&1"
echo: "0 0 * * 0 /srv/scripts/backup/borg-media-backup.sh >> /var/log/media-backup.log 2>&1"
