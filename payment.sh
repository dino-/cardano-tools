#! /bin/bash

basename=$(basename "$0")

usage="Usage: $basename FROM_WALLET TO_WALLET LOVELACE_AMT TX_IN#IX [TX_IN#IX TX_IN#IX...]"

[[ $# -lt 4 ]] && { echo "$usage"; exit 1; }

walletDir=${CARDANO_WALLET_DIR:?ERROR, this environment variable is not set}
walletFrom=$1
walletTo=$2
lovelace=$3
shift 3
txIn=$(printf " --tx-in %s" "$@")

[ -d "$walletDir" ] || { echo "Directory $walletDir doesn't exist!"; exit 1; }

set -e

templatePrefix="payment.XXXXXXXXXX"
tmpBody=$(mktemp --tmpdir=. ${templatePrefix}.body)
tmpSigned=$(mktemp --tmpdir=. ${templatePrefix}.signed)

# shellcheck disable=SC2086
$CARDANO_CLI transaction build \
  --alonzo-era \
  --testnet-magic "$TESTNET_MAGIC_NUM" \
  $txIn \
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
