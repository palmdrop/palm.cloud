#!/bin/bash

source /srv/server.env

# Create lab network
docker network create \
	--driver=bridge \
	--subnet=$SUBNET \
	$LAB_NETWORK

# Infrastructure network
docker network create $INFRA_NETWORK
