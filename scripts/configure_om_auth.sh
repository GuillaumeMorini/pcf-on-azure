#!/bin/bash

source ~/.env

om --skip-ssl-validation -t "${OM_TARGET}" \
  configure-authentication \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
    --decryption-passphrase "${OM_DECRYPTION_PASSPHRASE}"
