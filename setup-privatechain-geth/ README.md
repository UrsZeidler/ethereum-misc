### setup a private chain with geth

There are a lot of nice tutorials out for this ([here](https://lightrains.com/blogs/setup-local-ethereum-blockchain-private-testnet) and [here](http://www.skychain.com.au/skychain-blockchain-australia/2016/5/8/creating-a-private-chain-blockchain-testnet-with-geth-ethereum) for example)but mostly there are concentrated on using the private chain in the geth console. Here we want to setup a private chain and use it via rpc.

There are three bash scripts all of them are configured by the `private-chain.conf` so take a look and change what need to be changed for you. For example the path to the geth program, the network/chainid, data directory and so on. Take also a look at `genesis/genesis` which contains the template for the genesis.json file, you will need to change the account, remove it or add some.

* `setup-private-chain.sh` used to setup the chain, it writes the customized genesis.json and initialize the blockchain
* `start-private-chain.sh` start the created chain without a miner
* `start-private-chain-miner.sh` start the private chain with a miner
