#!/bin/bash

RESOURCE_GROUP=`(cat output.json | jq -r '.pcf_resource_group_name.value')`
SECURITY_GROUP=`(cat output.json | jq -r '.bosh_deployed_vms_security_group_name.value')`
NETWORK_NAME=`(cat output.json | jq -r '.network_name.value')`

# Pave new subnets for 'pks' and 'pks-services'
az network vnet subnet create --name $RESOURCE_GROUP-pks-subnet \
--vnet-name $NETWORK_NAME \
--resource-group $RESOURCE_GROUP \
--address-prefix 10.0.12.0/24 \
--network-security-group $SECURITY_GROUP

az network vnet subnet create --name $RESOURCE_GROUP-pks-services-subnet \
--vnet-name $NETWORK_NAME \
--resource-group $RESOURCE_GROUP \
--address-prefix 10.0.16.0/24 \
--network-security-group $SECURITY_GROUP
