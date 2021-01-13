export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

# Create Organization crypto material using cryptogen
if [ -d "organizations/peerOrganizations" ]; then
rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
fi
echo "Generate certificates using cryptogen tool"

echo "Create Org1 Identities"
set -x
cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
fi

echo "Create Org2 Identities"

set -x
cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
fi

echo "Create Org3 Identities"

set -x
cryptogen generate --config=./organizations/cryptogen/crypto-config-org3.yaml --output="organizations"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
fi


echo "Create Orderer Org Identities"

set -x
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
fi

echo "Generating Orderer Genesis block"

# Note: For some unknown reason (at least for now) the block file can't be
# named orderer.genesis.block or the orderer will fail to launch!
set -x
configtxgen -profile ThreeOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
echo "Failed to generate orderer genesis block..."
fi