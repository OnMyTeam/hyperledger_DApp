## hyperledger v2.2 localhost network 구축

하이퍼레저 v2.2를 활용하여 단일 host에서 여러개의 컨테이너로 네트워크를 구축함.<br>
<img src="images/image3.jpg" alt="drawing" width="450"/><br>
* Operating system: 18.04.02 LTS live-server
* Go version: 1.14
* NodeJS version: 12.18.3
* NPM version: 6.14.6
* Channel: mychannel
* Organization: Org1, Org2, Org3
* CA: 1개(Org1)
* DB: CouchDB
* TLS: false
* Consensus Type: Solo

## 1. Docker 설치

```
$ sudo apt install docker.io
$ sudo apt install docker-compose
$ sudo apt install software-properties-common
$ sudo usermod -aG docker $USER
$ sudo reboot
$ docker version 

```
<img src="images/image1.png" alt="drawing" width="450"/><br>
## 2. nodeJS 설치

```
$ sudo apt-get update 
$ sudo apt-get install build-essential libssl-dev
$ curl -sL http://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o install_nvm.sh
$ bash install_nvm.sh 
$ source ~/.profile
$ sudo reboot
$ nvm install v12.18.3
$ node -v
$ npm -v 
```
<img src="images/image2.png" alt="drawing" width="450"/><br>

## 3. Hyperledger fabric samples v2.2 설치
```
$ mkdir -p $HOME/go/{src,pkg,bin}
$ cd ~/go/src
$ curl -sSL http://bit.ly/2ysbOFE | bash -s -- 2.2.0 1.4.7
$ sudo apt install vim
$ sudo vim ~/.profile
  아래 참고하여 환경변수 등록
$ source ~/.profile
```
<img src="images/image4.png" alt="drawing" width="450"/><br>
## 4. localhost-network 디렉토리 이동
다운 받은 localhost-network 디렉토리를 설치한 fabric-samples 디렉토리로 이동 시킴.<br>
이후, fabric-samples 디렉토리에서 작업 진행
```
$ mv $HOME/hyperledger/tutorial/localhost-network/ $HOME/go/src/fabric-samples/
$ cd $HOME/go/src/fabric-samples
```
## 5. 네트워크 구성 및 확장
### 5.1 localhost-network directory
* application: hyperledger network 연동 및 admin, user 등록
* contract: chaincode(fabcar)
* network: 네트워크 구축
<br>
<img src="images/image5.png" alt="drawing" width="450"/><br>