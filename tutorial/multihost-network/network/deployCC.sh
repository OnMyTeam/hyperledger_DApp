# export FABRIC_CFG_PATH=$PWD/../../config/

CHANNEL_NAME=mychannel
CC_NAME=fabcar
CC_VERSION=1.0
CC_SRC_PATH=/opt/gopath/src/github.com/fabcar/go
CC_SEQUENCE=1
# import utils
. envVar.sh

## package the chaincode
echo "Packaging chaincode ...."
docker exec \
    cli \
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} \
        --lang golang \
        --label ${CC_NAME}_${CC_VERSION} 
sleep 3
## Install chaincode on peer0.org1 and peer0.org2 and peer0.org3

echo "Installing chaincode on peer0.org1..."
docker exec cli peer lifecycle chaincode install ${CC_NAME}.tar.gz
sleep 3


## approve the definition for org1, org2, org3
PACKAGE_ID=fabcar_1.0:2427ef724647f287869f089b304676df44c50f0471a079d5ee87ae9383187718
echo "PACKAGE_ID : ${PACKAGE_ID}"

echo  "approve the definition for org1"
docker exec \
    cli \
    peer lifecycle chaincode approveformyorg \
        -o orderer.example.com:7050 \
        -n fabcar \
        --channelID $CHANNEL_NAME \
        --version ${CC_VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${CC_SEQUENCE} \
        --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

## expect orgs(org1, org2) to have approved and org3 not to
docker exec \
    cli \
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME \
        --name ${CC_NAME} \
        --version ${CC_VERSION} \
        --sequence ${CC_SEQUENCE} \
        --output json \
        --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

echo  "now that we know for sure both orgs have approved, commit the definition"
docker exec \
    cli \
    peer lifecycle chaincode commit \
        -o orderer.example.com:7050 \
        --channelID $CHANNEL_NAME \
        --name ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        --version ${CC_VERSION} \
        --sequence ${CC_SEQUENCE} \
        --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"


## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
echo "invoke fcn call: initLedger"
setGlobals 1
docker exec \
    cli \
    peer chaincode invoke \
        -o orderer.example.com:7050 \
        -C $CHANNEL_NAME \
        -n ${CC_NAME} \
        --peerAddresses peer0.org1.example.com:7051 \
        --peerAddresses peer0.org2.example.com:9051 \
        -c '{"function":"initLedger","Args":[]}'
sleep 3

## Query the chaincode - this does require that the chaincode have the 'queryAllCars'
echo "query fcn call: queryAllCars"
docker exec \
    cli \
    peer chaincode query \
        -o orderer.example.com:7050 \
        -C $CHANNEL_NAME \
        -n ${CC_NAME} \
        -c '{"function":"queryAllCars","Args":[]}'
