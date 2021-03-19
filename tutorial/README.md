# hyperledger fabric



## Transaction flow
아래는 하이퍼레저 패브릭에서 트랜잭션 처리 과정을 설명합니다.<br>
하이퍼레저 패브릭을 처음 접하는 사람들을 위해 최대한 쉽게 설명하려고 노력을 했습니다만...<br>
아무래도 용어에 있어서 익숙하지 않은 사람에겐 다소 어려울 수도 있으니 큰 흐름에 있어서 트랜잭션이 어떻게 처리되는지만 이해해도 도움이 많이 되실 거라 생각됩니다. 아래의 설명은 [패브릭 문서](https://hyperledger-fabric.readthedocs.io/en/v2.2.0/txflow.html?highlight=transaction%20flow)의 `transaction flow`부분을 기준으로 설명한 것이니 자세한 설명을 원하시는 분은 직접 문서를 참고하시기 바랍니다.
<br><br>
### 1. Assumptions
<br>
트랜잭션 처리 과정을 설명하기 전 이미 채널은 구성되어있고 네트워크가 동작 중이며, 트랜잭션을 전송하는 사용자는 CA(Certificate Authority)에 의해 register와 enroll이 되어있어 네트워크에 인증하는데 필요한 증명서(Certificate)를 발급받았다고 가정합니다.<br>
chaincode는 각 Peer에 설치 되어있고, 설치한 체인코드에는 트랜잭션에 의해 실행될 함수들이 정의되어있습니다. chaincode를 설치한 Peer는 트랜잭션을 받으면 반드시 실행(simulation)을 해야하고 그 결과를 Client에게 전송해 주어야 합니다.

<br><br>
### 2. Client A initiates a transaction
<br>
<img src="images/image1.jpg" alt="drawing" width="700"/><br>
Client가 application(구매 사이트)에서 특정 물건을 구매하는 버튼을 눌렀다고 생각합니다. 버튼을 누르게 되면 SDK에 의해 특정 물건을 구매하는 행위를 담당하는 함수를 chaincode에서 실행하라고 transaction proposal을 Peer에게 보내게 됩니다. transaction proposal에는 





