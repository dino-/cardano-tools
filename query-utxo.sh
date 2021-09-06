#! /bin/bash

set -e

${CARDANO_CLI:-cardano-cli} query utxo \
  --testnet-magic "${TESTNET_MAGIC_NUM:?ERROR: TESTNET_MAGIC_NUM not set}" \
  --address "${1:?Usage: $0 ADDRESS}"
