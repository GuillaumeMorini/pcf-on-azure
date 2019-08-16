#!/bin/bash

source ~/.env

# Download and stage PAS
om download-product --output-directory ../downloads --pivnet-file-glob "srt*.pivotal" --pivnet-product-slug "elastic-runtime" --product-version $PAS_VERSION --pivnet-api-token $PCF_PIVNET_UAA_TOKEN
om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD upload-product --product ../downloads/srt*.pivotal
om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD stage-product --product-name "cf" --product-version $PAS_VERSION

# Download and stage PKS
om download-product --output-directory ../downloads --pivnet-file-glob "*.pivotal" --pivnet-product-slug "pivotal-container-service" --product-version $PKS_VERSION --pivnet-api-token $PCF_PIVNET_UAA_TOKEN
om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD upload-product --product ../downloads/pivotal-container-service*.pivotal

# Download and stage Harbor
om download-product --output-directory ../downloads --pivnet-file-glob "*.pivotal" --pivnet-product-slug "harbor-container-registry" --product-version $HARBOR_VERSION --pivnet-api-token $PCF_PIVNET_UAA_TOKEN
om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD upload-product --product ../downloads/harbor-container-registry*.pivotal

# Retrieve the exact build numbers
PKS_VERSION=`(om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD available-products -f json | jq -r '.[] | select(.name == "pivotal-container-service") | .version')`
HARBOR_VERSION=`(om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD available-products -f json | jq -r '.[] | select(.name == "harbor-container-registry") | .version')`

# Stage the PKS and Harbor tiles
om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD stage-product --product-name "pivotal-container-service" --product-version $PKS_VERSION
om -k -t $OM_TARGET -u $OM_USERNAME -p $OM_PASSWORD stage-product --product-name "harbor-container-registry" --product-version $HARBOR_VERSION
