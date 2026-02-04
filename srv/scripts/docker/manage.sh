#!/bin/bash

# set -eou pipefail

SERVER_DIR=/srv/
DOCKER_DIR=${SERVER_DIR}/docker

source "$SERVER_DIR/server.env"

# NOTE: twingate-ssh is excluded by design, to avoid accidentally killing the remote SSH connection
SERVICES=("caddy" "nextcloud" "pihole" "twingate-cloud")

docker_compose_up() {
    local service="$1"
    echo "Starting ${service}..."
    cd "${DOCKER_DIR}/${service}"
    docker compose up -d
}

docker_compose_down() {
    local service="$1"
    echo "Stopping ${service}..."
    cd "${DOCKER_DIR}/${service}"
    docker compose down
}

docker_compose_logs() {
    local service="$1"
    cd "${DOCKER_DIR}/${service}"
    docker compose logs -f
}

start() {
    if [ ! -z "$1" ]; then
        docker_compose_up "$1"
        return
    fi

    for service in "${SERVICES[@]}"; do
        docker_compose_up "$service"
    done
}

stop() {
    if [ ! -z "$1" ]; then
        docker_compose_down "$1"
        return
    fi

    for ((i=${#SERVICES[@]}-1; i>=0; i--)); do
        service="${SERVICES[$i]}"
        docker_compose_down "$service"
    done
}

logs() {
    if [ ! -z "$1" ]; then
        docker_compose_logs "$1"
        return
    fi
    
    for service in "${SERVICES[@]}"; do
        docker_compose_logs "$service"
    done
}

restart() {
    stop "$1"
    sleep 2
    start "$1"
}

status() {
    echo "=== Docker Services Status ==="
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

case "$1" in
    start)
        start "$2"
        ;;
    stop)
        stop "$2"
        ;;
    restart)
        restart "$2"
        ;;
    status)
        status
        ;;
    logs)
        logs "$2"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac



