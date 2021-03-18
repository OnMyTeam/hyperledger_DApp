export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false
export CHANNEL_NAME=mychannel
# Create Organization crypto material using cryptogen
if [ -d "organizations/peerOrganizations" ]; then
rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
fi
echo "Generate certificates using cryptogen tool"

echo "Create Org1 Identities"

cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"
if [ $? -ne 0 ]; then
    echo "Failed to generate certificates..."
fi

echo "Create Org2 Identities"
cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"
if [ $? -ne 0 ]; then
    echo "Failed to generate certificates..."
fi

echo "Create Orderer Org Identities"
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
if [ $? -ne 0 ]; then
    echo "Failed to generate certificates..."
fi

echo "Generating Orderer Genesis block"
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
if [ $? -ne 0 ]; then
echo "Failed to generate orderer genesis block..."
fi

# generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME


configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
