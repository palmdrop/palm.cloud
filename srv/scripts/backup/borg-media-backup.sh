#!/bin/bash

### SETUP ###

set -euo pipefail

source /srv/server.env

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

get_now() { 
    echo "$(date -u +"%Y-%m-%dT%H:%M:%S")";
}

start=$(get_now)

### SCRIPT ###

if [ ! -f "$BORG_PASSPHRASE_FILE" ]; then
	print_error "Passphrase file not found: $BORG_PASSPHRASE_FILE"
	exit 1
fi

export BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

BACKUP_NAME="media-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BORG_TEMP_DIR"

print_info "Starting Media backup: $BACKUP_NAME"

print_info "Enabling Nextcloud maintenance mode..."
docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --on

print_info "Creating Borg backup..."

borg create \
	--progress \
    --verbose \
	--compression lz4 \
	--exclude-caches \
	"$BORG_MEDIA_REPO::$BACKUP_NAME" \
	"$MEDIA_DIR"

print_info "Backup creation completed!"

print_info "Disabling Nextcloud maintenance mode..."
docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --off

### PRUNE ###
borg prune \
	--list \
	--stats	\
	--keep-daily=$BORG_KEEP_DAILY \
	--keep-weekly=$BORG_KEEP_WEEKLY \
	--keep-monthly=$BORG_KEEP_MONTHLY \
	--keep-yearly=$BORG_KEEP_YEARLY \
	"$BORG_MEDIA_REPO"

### VERIFY ###
print_info "Verifying backup integrity..."
if borg check \
    --verify-data \
    "$BORG_MEDIA_REPO::$BACKUP_NAME" 2>&1;
then
	print_info "Backup verified!"
else
	print_warn "Backup verification had warnings! Manual check required."
    log_error "Backup verification failed"
fi

### CLEANUP"
print_info "Cleaning up..."
rm -rf "$BORG_TEMP_DIR"

### RESULT ###
print_info "Backup completed successfully!"
print_info "Backup name: $BACKUP_NAME"
print_info "Repository: $BORG_MEDIA_REPO"

print_info "Available backups:"
borg list "$BORG_MEDIA_REPO"

exit 0
