#!/bin/bash
  
source ${HOME}/.env

cp ${HOME}/config/terraform.tfvars ${HOME}/pivotal*/terraforming-pas
cd ${HOME}/pivotal*/terraforming-pas

terraform init
terraform plan
terraform apply -auto-approve
