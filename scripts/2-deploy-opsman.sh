#!/bin/bash
  
source ${HOME}/.env

cp ${HOME}/config/terraform.tfvars ${HOME}/pivotal*/terraforming-pas
cd ${HOME}/pivotal*/terraforming-pas

terraform init
terraform plan
terraform apply -auto-approve

# generate the output file of Terraform in order to generate the configuration files
terraform output -json > ${HOME}/scripts/output.json

# pave subnets for PKS
cd ${HOME}/scripts
./create-pks-subnets.sh

# Prompt user to make the necessary changes on the DNS side
echo
echo "Please set up your DNS registrar with the appropriate NS records:"
cat output.json | jq -r '.env_dns_zone_name_servers.value'

