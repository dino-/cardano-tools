#! /bin/bash

set -e

${CARDANO_CLI:-cardano-cli} query tip \
  --testnet-magic ${TESTNET_MAGIC_NUM:?ERROR: TESTNET_MAGIC_NUM not set}
