#!/bin/bash

set -eou pipefail

SERVER_DIR=/srv
SERVER_ENV=$SERVER_DIR/server.env

source $SERVER_ENV

directories=($(find $SERVER_DIR/docker/ -type f -name 'docker-compose.yml' -exec dirname {} \;))

echo "Generating .env files..."

for dir in "${directories[@]}"; do
    env_file=${dir}/.env

    echo "Writing $env_file..."
    cat $SERVER_ENV > "$env_file"

    local_env_file="$dir/.env.local" 

    if [ -f "$local_env_file" ]; then
        echo "Found local env file: $local_env_file"

        echo "" >> "$env_file"
        echo "# .env.local" >> "$env_file"
        cat "$local_env_file" >> "$env_file"
    fi

    chmod 600 "$env_file"
done

echo "Done generating .env files!"

