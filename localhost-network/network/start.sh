

CHANNEL_NAME=mychannel
# default image tag
IMAGETAG="latest"
# default ca image tag
CA_IMAGETAG="latest"
export FABRIC_CFG_PATH=${PWD}/configtx
# export CORE_PEER_TLS_ENABLED=true
# import utils
. envVar.sh

# Shut down the Docker containers for the system tests.
docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml kill 
docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-ca.yaml down


IMAGE_TAG=$IMAGETAG docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml up -d
IMAGE_TAG=$CA_IMAGETAG docker-compose -f docker/docker-compose-ca.yaml up -d ca_org1

docker ps -a



# generate channel configuration transaction
configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME


# generate anchor peer transaction
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
# generate anchor peer transaction
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
# generate anchor peer transaction
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP


export FABRIC_CFG_PATH=${PWD}/../../config/
setGlobals 1
# Create the channel
echo "Creating channel ${CHANNEL_NAME}"
peer channel create -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block
sleep 3


# Join peer0.org1.example.com to the channel.
echo "Join Org1 peers to the channel..."
setGlobals 1
CORE_PEER_TLS_ENABLED=false 
peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block 
sleep 3

# Join peer0.org2.example.com to the channel.
echo "Join Org2 peers to the channel..."
setGlobals 2
CORE_PEER_TLS_ENABLED=false 
peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
sleep 3

# Join peer0.org3.example.com to the channel.
echo "Join Org3 peers to the channel..."
setGlobals 3
CORE_PEER_TLS_ENABLED=false 
peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
sleep 3

# Updating anchor peers for org1...
echo "Updating anchor peers for org1..."
setGlobals 1
peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx
sleep 3

# Updating anchor peers for org2...
echo "Updating anchor peers for org2..."
setGlobals 2
peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx
sleep 3

# Updating anchor peers for org3...
echo "Updating anchor peers for org3..."
setGlobals 3
peer channel update -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org3MSPanchors.tx
sleep 3