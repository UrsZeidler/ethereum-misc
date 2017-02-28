#!/bin/bash

source private-chain.conf;

## remove the datadir
rm -R $DATADIR/geth


## set the chain id to the network id
sed -e "s/CHAINID/${NETWORKID}/" $GENESIS_TMPL > ${GENESIS}

$GETH --datadir "$DATADIR" --identity "$IDENTITY" --networkid $NETWORKID  init $GENESIS 

## remove the generated file
rm $GENESIS
