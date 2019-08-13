#!/bin/bash

SUBSCRIPTION_ID=`(cat output.json | jq -r '.subscription_id.value')`
TENANT_ID=`(cat output.json | jq -r '.tenant_id.value')`
APPLICATION_ID=`(cat output.json | jq -r '.client_id.value')`
CLIENT_SECRET=`(cat output.json | jq -r '.client_secret.value')`
RESOURCE_GROUP=`(cat output.json | jq -r '.pcf_resource_group_name.value')`
BOSH_STORAGE=`(cat output.json | jq -r '.bosh_root_storage_account.value')`
SECURITY_GROUP=`(cat output.json | jq -r '.bosh_deployed_vms_security_group_name.value')`
SSH_PUBLIC_KEY=`(cat output.json | jq -r '.ops_manager_ssh_public_key.value')`
SSH_PRIVATE_KEY=`(cat output.json | jq -r '.ops_manager_ssh_private_key.value')`
NTP_SERVER=pool.ntp.org
DNS=168.63.129.16
NETWORK_NAME=`(cat output.json | jq -r '.network_name.value')`



cat > "director-config.yml" <<-EOF
# director-config.yml

PCF_SUBSCRIPTION_ID: "${SUBSCRIPTION_ID}"
PCF_TENANT_ID: "${TENANT_ID}"
PCF_APPLICATION_ID: "${APPLICATION_ID}"
PCF_CLIENT_SECRET: "${CLIENT_SECRET}"
PCF_RESOURCE_GROUP: "${RESOURCE_GROUP}"
PCF_BOSH_STORAGE: "${BOSH_STORAGE}"
PCF_SECURITY_GROUP: "${SECURITY_GROUP}"
PCF_SSH_PUBLIC_KEY: "${SSH_PUBLIC_KEY}"
PCF_SSH_PRIVATE_KEY: "${SSH_PRIVATE_KEY}"
PCF_NTP_SERVER: $NTP_SERVER
PCF_DNS: $DNS
PCF_MANAGEMENT_NETWORK: $MANAGEMENT_NETWORK
PCF_MANAGEMENT_CIDR: $MANAGEMENT_CIDR
PCF_MANAGEMENT_GATEWAY: $MANAGEMENT_GW
PCF_MANAGEMENT_RESERVED_IPS: $MANAGEMENT_RESERVED_IPS
PCF_PAS_NETWORK: $PAS_NETWORK
PCF_PAS_CIDR: $PAS_CIDR
PCF_PAS_GATEWAY: $PAS_GW
PCF_PAS_RESERVED_IPS: $PAS_RESERVED_IPS
PCF_SERVICES_NETWORK: $SERVICES_NETWORK
PCF_SERVICES_CIDR: $SERVICES_CIDR
PCF_SERVICES_GATEWAY: $SERVICES_GW
PCF_SERVICES_RESERVED_IPS: $SERVICES_RESERVED_IPS
EOF
