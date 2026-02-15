#!/bin/bash

docker system prune -af --volumes
docker volume rm $(docker volume ls -qf dangling=true)


