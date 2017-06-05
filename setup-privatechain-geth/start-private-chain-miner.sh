#!/bin/bash

source private-chain.conf;

$GETH --mine --minerthreads 1 --nodiscover --maxpeers 0 --nat none --datadir "$DATADIR" --identity "$IDENTITY" --rpc --rpcport "$RPC_PORT" --networkid $NETWORKID console
