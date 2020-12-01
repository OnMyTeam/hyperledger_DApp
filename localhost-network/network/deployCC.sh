export FABRIC_CFG_PATH=$PWD/../../config/

CHANNEL_NAME=mychannel
CC_NAME=fabcar
CC_VERSION=1.0
CC_SRC_PATH=../contract/fabcar
CC_SEQUENCE=1
# import utils
. envVar.sh

## package the chaincode
echo "Packaging chaincode ...."
setGlobals 1
peer lifecycle chaincode package ${CC_NAME}.tar.gz \
--path ${CC_SRC_PATH} \
--lang golang \
--label ${CC_NAME}_${CC_VERSION} 

## Install chaincode on peer0.org1 and peer0.org2 and peer0.org3

echo "Installing chaincode on peer0.org1..."
setGlobals 1
peer lifecycle chaincode install ${CC_NAME}.tar.gz
sleep 3

echo "Installing chaincode on peer0.org2..."
setGlobals 2
peer lifecycle chaincode install ${CC_NAME}.tar.gz
sleep 3

echo "Installing chaincode on peer0.org3..."
setGlobals 3
peer lifecycle chaincode install ${CC_NAME}.tar.gz
sleep 3

## approve the definition for org1, org2, org3
PACKAGE_ID=fabcar_1.0:b41ab9af76a078ae8af2b9897c51f6a0c401e4c6c777414d766698b1b7fac00a
# PACKAGE_ID=fabcar_2.0:0cac52a2428e6bc85337cbd6f0b230ced5f8112171da81102948d63e1c9c690f
echo "PACKAGE_ID : ${PACKAGE_ID}"

echo  "approve the definition for org1"
setGlobals 1
peer lifecycle chaincode approveformyorg \
-o localhost:7050 \
-n fabcar \
--channelID $CHANNEL_NAME \
--version ${CC_VERSION} \
--package-id ${PACKAGE_ID} \
--sequence ${CC_SEQUENCE} \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

# checkCommitReadiness VERSION PEER ORG
## check whether the chaincode definition is ready to be committed
## expect org1 to have approved and org2, org3 not to
setGlobals 1
peer lifecycle chaincode checkcommitreadiness \
--channelID $CHANNEL_NAME \
--name ${CC_NAME} \
--version ${CC_VERSION} \
--sequence ${CC_SEQUENCE} \
--output json \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

echo  "approve the definition for org2"
setGlobals 2
peer lifecycle chaincode approveformyorg \
-o localhost:7050 \
-n fabcar \
--channelID $CHANNEL_NAME \
--version ${CC_VERSION} \
--package-id ${PACKAGE_ID} \
--sequence ${CC_SEQUENCE} \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

# checkCommitReadiness VERSION PEER ORG
## check whether the chaincode definition is ready to be committed
## expect orgs(org1, org2) to have approved and org3 not to
setGlobals 2
peer lifecycle chaincode checkcommitreadiness \
--channelID $CHANNEL_NAME \
--name ${CC_NAME} \
--version ${CC_VERSION} \
--sequence ${CC_SEQUENCE} \
--output json \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

echo  "approve the definition for org3"
setGlobals 3
peer lifecycle chaincode approveformyorg \
-o localhost:7050 \
-n fabcar \
--channelID $CHANNEL_NAME \
--version ${CC_VERSION} \
--package-id ${PACKAGE_ID} \
--sequence ${CC_SEQUENCE} \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

# checkCommitReadiness VERSION PEER ORG
## check whether the chaincode definition is ready to be committed
## expect orgs(org1, org2, org3) to have approved
setGlobals 3
peer lifecycle chaincode checkcommitreadiness \
--channelID $CHANNEL_NAME \
--name ${CC_NAME} \
--version ${CC_VERSION} \
--sequence ${CC_SEQUENCE} \
--output json \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"


## now that we know for sure both orgs have approved, commit the definition
# commitChaincodeDefinition VERSION PEER ORG (PEER ORG)...
echo  "now that we know for sure both orgs have approved, commit the definition"
peer lifecycle chaincode commit \
-o localhost:7050 \
--channelID $CHANNEL_NAME \
--name ${CC_NAME} \
--peerAddresses localhost:7051 \
--peerAddresses localhost:9051 \
--peerAddresses localhost:11051 \
--version ${CC_VERSION} \
--sequence ${CC_SEQUENCE} \
--signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

## query on both orgs to see that the definition committed successfully
echo "query on both orgs to see that the definition committed successfully"

echo "Querying chaincode definition on peer0.org1 on channel '$CHANNEL_NAME'..."
setGlobals 1
peer lifecycle chaincode querycommitted \
--channelID $CHANNEL_NAME \
--name ${CC_NAME}

echo "Querying chaincode definition on peer0.org2 on channel '$CHANNEL_NAME'..."
setGlobals 2
peer lifecycle chaincode querycommitted \
--channelID $CHANNEL_NAME \
--name ${CC_NAME}

echo "Querying chaincode definition on peer0.org3 on channel '$CHANNEL_NAME'..."
setGlobals 3
peer lifecycle chaincode querycommitted \
--channelID $CHANNEL_NAME \
--name ${CC_NAME}


## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
echo "invoke fcn call: initLedger"

peer chaincode invoke \
-o localhost:7050 \
-C $CHANNEL_NAME \
-n ${CC_NAME} \
--peerAddresses localhost:7051 \
--peerAddresses localhost:9051 \
--peerAddresses localhost:11051 \
-c '{"function":"initLedger","Args":[]}'