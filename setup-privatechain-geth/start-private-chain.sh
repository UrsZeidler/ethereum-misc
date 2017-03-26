#!/bin/bash

source private-chain.conf;

$GETH --datadir "$DATADIR" --identity "$IDENTITY" --rpc --rpcport "$RPC_PORT" --port "30303" --nodiscover  --autodag --networkid "$NETWORKID"  "$@"
