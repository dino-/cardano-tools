#! /bin/bash


basename=$(basename "$0")


usage=$(cat <<USAGE
Helper script for generating Cardano wallet key and address files

usage:
  $basename [OPTIONS] WALLET_DIR WALLET_NAME

options:
  -h, --help  This help information

When successful the following files will be produced

    WALLET_DIR/WALLET_NAME.addr
    WALLET_DIR/WALLET_NAME.payment.skey
    WALLET_DIR/WALLET_NAME.payment.vkey
    WALLET_DIR/WALLET_NAME.stake.skey
    WALLET_DIR/WALLET_NAME.stake.vkey

v1.1  2021-09-02  Dino Morelli <dino@ui3.info>

USAGE
)


warn () {
  echo "$basename:" "$@" >&2
}


die () {
  rc="$1"
  shift
  warn "$@"
  exit "$rc"
}


# arg parsing

getoptResults=$(getopt -o h --long help -n "$basename" -- "$@") \
  || die 1 "$usage"

# Note the quotes around "$getoptResults": they are essential!
eval set -- "$getoptResults"

optHelp=false

while true ; do
  case "$1" in
    -h|--help) optHelp=true; shift;;
    --) shift; break;;
  esac
done

$optHelp && die 0 "$usage"

if [ $# -lt 2 ]
then
  warn "Incorrect number of arguments"
  die 1 "$usage"
fi

walletDir="$1"
walletName="$2"

[ -z "$TESTNET_MAGIC_NUM" ] \
  && die 1 "Can't continue because the TESTNET_MAGIC_NUM environment variable is not set"

cd "$walletDir" || die 1 "Can't change directory to $walletDir"

set -e

# Support either an explicit env variable or the cardano CLI tool on the PATH
cardanoCli=${CARDANO_CLI:=cardano-cli}

# Create a payment key pair
$cardanoCli address key-gen \
  --verification-key-file "${walletName}.payment.vkey" \
  --signing-key-file "${walletName}.payment.skey"

# Create a stake key pair
$cardanoCli stake-address key-gen \
  --verification-key-file "${walletName}.stake.vkey" \
  --signing-key-file "${walletName}.stake.skey"

# Create a payment address
$cardanoCli address build \
  --testnet-magic "$TESTNET_MAGIC_NUM" \
  --payment-verification-key-file "${walletName}.payment.vkey" \
  --stake-verification-key-file "${walletName}.stake.vkey" \
  --out-file "${walletName}.addr"
