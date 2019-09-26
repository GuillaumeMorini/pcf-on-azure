#!/bin/bash

source "${HOME}/.env"
echo "Initializing Pivotal Cloud Foundry Operations Manager ${OPSMAN_VERSION}"


PRODUCT_NAME="Pivotal Application Service" \
DOWNLOAD_REGEX="Azure Terraform Templates" \
PRODUCT_VERSION=${PAS_VERSION} \
  ${HOME}/scripts/download-product.sh || exit 1
unzip -o ${HOME}/downloads/elastic-runtime_${PAS_VERSION}_*/terraforming-azure-*.zip -d ${HOME}

