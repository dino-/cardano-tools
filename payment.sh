#! /bin/bash

basename=$(basename "$0")

usage="Usage: $basename WALLET_DIR FROM_WALLET TX_IN LOVELACE_AMT TO_WALLET"

[[ $# -lt 5 ]] && { echo "$usage"; exit 1; }

walletDir=$1
walletFrom=$2
txIn=$3
lovelace=$4
walletTo=$5

[ -d "$walletDir" ] || { echo "Directory $walletDir doesn't exist!"; exit 1; }

set -e

templatePrefix="payment.XXXXXXXXXX"
tmpBody=$(mktemp --tmpdir=. ${templatePrefix}.body)
tmpSigned=$(mktemp --tmpdir=. ${templatePrefix}.signed)

$CARDANO_CLI transaction build \
  --alonzo-era \
  --testnet-magic "$TESTNET_MAGIC_NUM" \
  --tx-in "$txIn" \
  --tx-out "$(cat "${walletDir}"/"${walletTo}".addr)+${lovelace}" \
  --change-address "$(cat "${walletDir}"/"${walletFrom}".addr)" \
  --out-file "$tmpBody"

$CARDANO_CLI transaction sign \
  --testnet-magic "$TESTNET_MAGIC_NUM" \
  --tx-body-file "$tmpBody" \
  --signing-key-file "${walletDir}/${walletFrom}.payment.skey" \
  --out-file "$tmpSigned"

$CARDANO_CLI transaction submit \
  --testnet-magic "$TESTNET_MAGIC_NUM" \
  --tx-file "$tmpSigned"

rm "$tmpBody" "$tmpSigned"
