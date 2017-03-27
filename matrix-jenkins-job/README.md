# build a matrix job in jekins to junit test the smart contracts on different implementations

This document describes the building of a continuous integration job in Jenkis to test the smart contracts with junit on the different implementations always in a private test net. The project is assumed to be build with [uml2solidity](https://github.com/UrsZeidler/uml2solidity). You find out more about this [here](https://github.com/UrsZeidler/uml2solidity/wiki/JavaCode).

requisite:  

* [Jenkis](https://jenkins.io/index.html)
	* Maven Integration plugin (part of Jenkins)
	* Matrix Project plugin
* [geth]()
	
## create a matrix job

Select `new Item` and choose the `Multi-configuration project`. Fill in your job name and hit save.

## configure the matrix job

Select your `Source Code Management` and define the `Build Triggers`.

## define the axis

The important configuration is the `Configuration Matrix`

![configer matrix](https://github.com/UrsZeidler/ethereum-misc/blob/master/matrix-jenkins-job/images/configure-matrix-job.png)

Here we define the different implementations as axis. The Parameter is defined as `EFP` and will be used later on. You should check the `Run each configuration sequentially` checkbox.

The current parameters are:

* standalone - The standanlone blockchain 
* private - a private chain with EthereumJ
* rpc - using the web3j connector to access a private geth chain

## Build

In the build section we define all the build steps nessesary.

### prepare the private chain

We need to add an `Execute shell` build step. This build step will create a private geth chain and it will be only started when we run the `rpc` implementation. Paste the following bash script in the `command` text area. This script will setup a private chain with geth and start a geth instance to mine this chain. Take a look at the parameters like the `NETWORKID` and very important is the `GETH` parameter as it defines where to find the geth instance.

```bash
#!/bin/bash

#######
###
### creates and setup a private chain with geth
### 
### (c) urs zeidler
###
#######


## check if we need to start geth
## useful when doing a matrix job in jenkins
if [ "$EFP" != "rpc" ]; then
	exit
fi


## the main data
BASEDIR=chainData
GENESIS=genesis/genesis.json
IDENTITY=privateChain
DATADIR=$IDENTITY
NETWORKID=33
RPC_PORT=8545

## customize the path to geth
GETH=/path to geth/geth

## remove the old datadir
rm -f -R $BASEDIR

## create the directories
mkdir -p $BASEDIR/genesis 
mkdir -p $BASEDIR/$DATADIR/keystore

cd $BASEDIR

## write the genesis file add your accounts with money at the alloc section
echo '{
"config": {
    "chainId": '"${NETWORKID}"',
        "homesteadBlock":0,
        "eip150Block":0,
        "eip155Block":10,
        "eip158Block":10,
        "eip160Block":10
    },
	"nonce": "0x0000000000000042",
	"timestamp": "0x0",
	"parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
	"extraData": "0x0",
	"gasLimit": "0x2fefd8",
	"difficulty": "0x400",
	"mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
	"coinbase": "0x0000000000000000000000000000000000000000",
	"alloc": 
	{
		"0x82383d27a794c0be662b4726856b56cbdcbf5885": 
		{
			"balance": "4000000000000000000000"
		},
		"0x9aacd1a8806010180de44f90f92c55ada7193254": 
		{
			"balance": "4000000000000000000000"
		}
	}
}' > $GENESIS

## add your generated private keys like this if you need more
## create the private keys which are valid in the private network
echo '{"address":"82383d27a794c0be662b4726856b56cbdcbf5885",
"crypto":{"cipher":"aes-128-ctr","ciphertext":"cbca65ed81aea71c09a1ff243d59a4034444d881eebe74144eb9c129d73745e0",
"cipherparams":{"iv":"54d728265d8422e3c13d8264705e22da"},
"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,
"salt":"ce16815a75fe041b6bf52207c4e29cbac497b040f3720c3961cc3743652e4955"},
"mac":"7a250fd3058958e9a793e259ad3b50205584e278ab89e96d73a81420f31d65c1"},
"id":"c17b2acf-cae6-4121-a3dd-fe4938d13c70","version":3}' > $DATADIR/keystore/UTC--2017-02-26T17-45-15.563637757Z--82383d27a794c0be662b4726856b56cbdcbf5885
	
	
echo '{"address":"9aacd1a8806010180de44f90f92c55ada7193254",
"crypto":{"cipher":"aes-128-ctr","ciphertext":"1ed52183456742ee0c6ab386d37480e73d02aba0fc09ec06183d60588ac72ac8",
"cipherparams":{"iv":"4396312dc38dce5bd6a793749b2ad643"},
"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,
"salt":"c94f867daa6818852a83725aa3582e66928d1a7f66393608be3f0fb229a199e6"},
"mac":"797ed18c2b450f144224779327b4ed6f6817dc24763624c0ef3c1680fce1be54"},
"id":"e2a2272b-7cd2-49b1-baa4-a83d79df44bc","version":3}' > $DATADIR/keystore/UTC--2017-02-27T20-10-53.066400300Z--9aacd1a8806010180de44f90f92c55ada7193254


echo "starting geth to init the chain ..."
## initialize the chain
$GETH --datadir "$DATADIR" --identity "$IDENTITY" --networkid $NETWORKID  init $GENESIS 

## remove the generated file genesis file
rm $GENESIS

echo "starting geth to mine the chain ..."
## now start the geth miner
$GETH --mine --minerthreads 1 --nodiscover --maxpeers 0 --nat none --datadir "$DATADIR" --identity "$IDENTITY" --rpc --rpcport "$RPC_PORT" --autodag --networkid $NETWORKID &

some_pid=$!

echo "geth started with pid=$some_pid"

## safe the pid to stop geth later
echo $some_pid > geth.pid
```

We make sure geth is only started when we run on the rpc, then we create the necessary directories and files like the genesis file and the accounts we use. We initialize the chain and start the geth miner.
At last we store the geth-miner pid as we need it to stop the geth miner after the tests are done.

### build the software

![maven config](https://github.com/UrsZeidler/ethereum-misc/blob/master/matrix-jenkins-job/images/maven-config.png)

As the software is a maven project select `Invoke top-level Maven targets` in the parameter section we define the necessary parameters and link them to the defined matrix parameter. See the [java code](https://github.com/UrsZeidler/uml2solidity/wiki/JavaCode#ethereuminstance) wiki page for uml2solidity. Here we need of course the main `EthereumFacadeProvider` parameter and the `chain-id` while the `EthereumFacadeProvider` is filled by the axis parameter each time the build is started, the `chain-id` has to match the `NETWORKID` defined in the shell script.

### after the build

After the build we stop the geh instance. So we use a `Execute shell` again.

```bash
#!/bin/bash

if [ "$EFP" == "rpc" ]; then
	kill $(cat geth.pid)
fi

```


