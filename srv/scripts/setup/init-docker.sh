#!/bin/bash

source /srv/server.env

# Create shared network
docker network create \
	--driver=bridge \
	--subnet=$SUBNET \
	palmcloud
