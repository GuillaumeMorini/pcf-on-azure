#!/bin/bash

source ~/.env

om --skip-ssl-validation -t "${OM_TARGET}" \
  configure-authentication \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
    --decryption-passphrase "${OM_DECRYPTION_PASSPHRASE}"

# Generate the BOSH director variable file
./create-director-config.sh

#
# Configure Ops Manager with the correct settings
#
om --skip-ssl-validation -t "${OM_TARGET}" -tr \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
  configure-director \
    --config "director-template-${OPSMAN_VERSION}.yml" \
    --vars-file "director-config.yml"


#
# Apply changes to Director
#
om --skip-ssl-validation -t "${OM_TARGET}" -tr \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
  apply-changes \
    --skip-deploy-products
