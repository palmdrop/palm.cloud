#!/bin/bash

source /srv/server.env

docker exec -u www-data $NEXTCLOUD_CONTAINER php occ "$@"
