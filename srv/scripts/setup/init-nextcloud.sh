#!/bin/bash

# Disable skeleton directory
./scripts/occ-system-config.sh skeletondirectory --value=""

# Set maintenance window
./scripts/occ-system-config.sh maintenance_window_start --value="1" --type=integer

# TODO: I've also created the /data/tmp directory inside nextcloud 
# TODO: I also set the tmp directory to /var/www/html/data/tmp
