#!/bin/bash

source ./.env

docker exec -u www-data $NEXTCLOUD_CONTAINER php occ "$@"
