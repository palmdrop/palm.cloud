#!/bin/bash

SOURCE="$1"
DESTINATION="$2"
NAME="${3:-backup}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="${NAME}_${TIMESTAMP}"
TEMP_ARCHIVE="/tmp/${BACKUP_NAME}.tar.xz"
ENCRYPTED_ARCHIVE="${DESTINATION}/${BACKUP_NAME}.tar.xz.gpg"

# Create compressed archive
echo "Compressing data..."

tar -cvJf "$TEMP_ARCHIVE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

if [ ! -f "$TEMP_ARCHIVE" ]; then
	echo "ERROR: Failed to create archive"
	exit 1
fi

echo "Encrypting data..."
gpg --symmetric --cipher-algo AES256 --no-symkey-cache --output "$ENCRYPTED_ARCHIVE" "$TEMP_ARCHIVE"

if [ ! -f "$ENCRYPTED_ARCHIVE" ]; then
	echo "ERROR: Failed to encrypt archive"
	rm -f "$TEMP_ARCHIVE"
	exit 1
fi
