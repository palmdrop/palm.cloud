#!/bin/bash

SOURCE="$1"
FILE_NAME=$(basename "$SOURCE")
NAME="${FILE_NAME%.gpg}"
DESTINATION_DIR="$2"
DESTINATION="$DESTINATION_DIR/$NAME"

gpg --no-symkey-cache --decrypt "$SOURCE" > "$DESTINATION"
tar -xJf "$DESTINATION"
