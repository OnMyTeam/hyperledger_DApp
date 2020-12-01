#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml down --volumes --remove-orphans
# Shut down the Docker containers for the system tests.
docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml kill 
docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml down

# remove orderer block and other channel configuration transactions and certs
rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations channel-artifacts

rm -rf mychannel*.block
rm -rf *.tar.gz
# Your system is now clean
