#!/bin/bash

set -eou pipefail

source /srv/server.env

### SETUP ###

TMP_DIR=/tmp/restore
BACKUP_NAME=$1

export BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"

### RESTORE ###

mkdir -p $TMP_DIR
cd $TMP_DIR

echo "Extracting borg data..."
borg extract $BORG_REPO::$BACKUP_NAME

echo "Shutting down Nextcloud..."
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ maintenance:mode --on

cd /srv/docker/nextlcoud

# 1. Stop everything
docker compose down

# 2. Restore Nextcloud data files
sudo rm -rf $NEXTCLOUD_DATA_DIR/*
sudo cp -a ${TMP_DIR}${NEXTCLOUD_DATA_DIR}/* $NEXTCLOUD_DATA_DIR/

# 3. Start containers
docker compose up db -d

# 4. Wait for database to be ready
# TODO: better way of waiting? do I need to wait?
sleep 10

# 5. Terminate all connections to the nextcloud database
docker exec -i $POSTGRES_CONTAINER psql -U $DB_USER postgres <<EOF
-- Kill active connections
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'nextcloud'
  AND pid <> pg_backend_pid();

-- Drop & recreate DB
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud
  WITH OWNER nextcloud
  ENCODING 'UTF8'
  TEMPLATE template0;
EOF

# 7. Restore database
gunzip < $TMP_DIR/$BORG_DB_DUMP_FILE | \
    docker exec -i $POSTGRES_CONTAINER psql -U $DB_USER $DB_NAME

docker compose up -d

# 8. Disable maintenance mode
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ maintenance:mode --off

# 9. Cleanup
echo "Removing temporary data"
rm -rf $TMP_DIR

chown -R 33:33 $NEXTCLOUD_DATA_DIR
find $NEXTCLOUD_DATA_DIR -type d -exec chmod 750 {} \;
find $NEXTCLOUD_DATA_DIR -type f -exec chmod 640 {} \;

docker exec -u www-data $NEXTCLOUD_CONTAINER php occ maintenance:repair

echo "BACKUP RESTORED!"

