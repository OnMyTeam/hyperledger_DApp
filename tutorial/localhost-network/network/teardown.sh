#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

# # remove orderer block and other channel configuration transactions and certs
# rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations channel-artifacts

docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml down --volumes --remove-orphans
# Shut down the Docker containers for the system tests.
docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml kill 
docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml down

CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
echo "No containers available for deletion"
else
docker rm -f $CONTAINER_IDS
fi

DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
echo "No images available for deletion"
else
docker rmi -f $DOCKER_IMAGE_IDS
fi

# # remove orderer block and other channel configuration transactions and certs
# docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations'

# # remove channel and script artifacts
# docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'




# Your system is now clean
