export FABRIC_CFG_PATH=$PWD/../../config/

CHANNEL_NAME=mychannel
CC_NAME=fabcar
CC_VERSION=1.0
CC_SRC_PATH=../contract/fabcar/go
CC_SEQUENCE=1
#?import?utils
. envVar.sh

## Install chaincode on peer0.org1 and peer0.org2 and peer0.org3

echo "Installing chaincode on peer0.org1..."
setGlobals 1
peer chaincode install -n fabcar -v 1.0 -p "$CC_SRC_PATH"
sleep 3

echo "Installing chaincode on peer0.org2..."
setGlobals 2
peer chaincode install -n fabcar -v 1.0 -p "$CC_SRC_PATH"
sleep 3

echo "Installing chaincode on peer0.org3..."
setGlobals 3
peer chaincode install -n fabcar -v 1.0 -p "$CC_SRC_PATH"
sleep 3

setGlobals 1

peer chaincode instantiate \
-o localhost:7050 \
-C mychannel \
-n fabcar \
-v 1.0 \
-c '{"Args":[]}' \
-P "AND('Org1MSP.member','Org2MSP.member', 'Org3MSP.member')"