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


IMAGE_TAG=$IMAGETAG docker-compose -f docker/docker-compose-test-net.yaml -f docker/docker-compose-couch.yaml up -d peer0.org1.example.com cli
IMAGE_TAG=$CA_IMAGETAG docker-compose -f docker/docker-compose-ca.yaml up -d ca_org1

docker ps -a





# export FABRIC_CFG_PATH=${PWD}/../../config/
# setGlobals 1
# Create the channel
# echo "Creating channel ${CHANNEL_NAME}"
# peer channel create -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block
# sleep 3

echo "Org1 peers fetch the mychannel.block to join channel..."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com  peer channel fetch 0 -c mychannel --orderer orderer.example.com:7050

sleep 3
# Join peer0.org1.example.com to the channel.
echo "Join Org1 peers to the channel..."

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/"$CHANNEL_NAME"_0.block
sleep 3


# Updating anchor peers for org1...
echo "Updating anchor peers for org1..."
setGlobals 2
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f /etc/hyperledger/configtx/Org1MSPanchors.tx
sleep 3

