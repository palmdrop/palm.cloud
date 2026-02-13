#!/bin/bash

### SETUP ###

set -euo pipefail

source /srv/server.env

STATUS_DIR="$BACKUP_STATUS_DIR"
STATUS_FILE="$BORG_STATUS_FILE"
tmp_status=$(mktemp)

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

log_error() {
    end=$(get_now)
    jq -n --arg end "$end" --arg err "$1" '
        {
            backup: "borg",
            last_run: $end,
            status: "error",
            error: $err
        }
    ' > "$STATUS_FILE.tmp"
}

log_success() {
    end=$(get_now)

    jq --arg start "$start" \
       --arg end "$end" \
       '
       {
         backup: "borg",
         last_run: $end,
         started_at: $start,
         status: "ok",
         archive: .archive.name,
         duration_seconds: .archive.duration,
         stats: .archive.stats
       }
       ' "$tmp_status" >"$STATUS_FILE.tmp"
}

### SCRIPT ###

if [ ! -f "$BORG_PASSPHRASE_FILE" ]; then
	print_error "Passphrase file not found: $BORG_PASSPHRASE_FILE"
	exit 1
fi

export BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

TMP_CONFIG_FILE="$BORG_TEMP_DIR/config.php"
BACKUP_NAME="nextcloud-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BORG_TEMP_DIR"
mkdir -p "$STATUS_DIR"

print_info "Starting Nextcloud backup: $BACKUP_NAME"

print_info "Enabling Nextcloud maintenance mode..."
docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --on

print_info "Dumping database..."
docker exec "$POSTGRES_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BORG_DB_DUMP_FILE"

print_info "Copying config file..." 
docker exec -u www-data "$NEXTCLOUD_CONTAINER" cat config/config.php > "$TMP_CONFIG_FILE"

if [ ! -f "$BORG_DB_DUMP_FILE" ]; then
	print_error "Database dump failed!"
	docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --off

    log_error "Database dump failed"
    mv "$STATUS_FILE.tmp" "$STATUS_FILE"

	exit 1
fi

DB_SIZE=$(du -h "$BORG_DB_DUMP_FILE" | cut -f1)
print_info "Database dump complete: $DB_SIZE"

print_info "Creating Borg backup..."

if borg create \
	--stats \
    --json \
	--compression lz4 \
	--exclude-caches \
    --exclude "$NEXTCLOUD_DATA_DIR/appdata_*" \
	"$BORG_REPO::$BACKUP_NAME" \
	"$NEXTCLOUD_DATA_DIR" \
	"$BORG_DB_DUMP_FILE" \
	"$TMP_CONFIG_FILE" > "$tmp_status" 2>&1;
then
    log_success
else
	docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --off
	rm -rf "$BORG_TEMP_DIR"
	print_error "Borg backup failed!"

    log_error "$(tail -n 50 "$tmp_status")"
     
    mv "$STATUS_FILE.tmp" "$STATUS_FILE"
	exit 1
fi

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
	"$BORG_REPO"

### VERIFY ###
print_info "Verifying backup integrity..."
if borg check \
    --verify-data \
    "$BORG_REPO::$BACKUP_NAME" 2>&1;
then
	print_info "Backup verified!"
else
	print_warn "Backup verification had warnings! Manual check required."
    log_error "Backup verification failed"
fi

### CLEANUP"
print_info "Cleaning up..."
rm -rf "$BORG_TEMP_DIR"
rm -r "$tmp_status"

mv "$STATUS_FILE.tmp" "$STATUS_FILE"

### RESULT ###
print_info "Backup completed successfully!"
print_info "Backup name: $BACKUP_NAME"
print_info "Repository: $BORG_REPO"

print_info "Available backups:"
borg list "$BORG_REPO"

exit 0
