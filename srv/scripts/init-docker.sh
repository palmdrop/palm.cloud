#!/bin/bash

source /srv/server.config.env

# Create shared network
#docker network create palmcloud 
docker network create \
	--driver=bridge \
	--subnet=$SUBNET \
	palmcloud
