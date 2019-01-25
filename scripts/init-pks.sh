#!/bin/bash

source ${HOME}/.env

cp ${HOME}/config/terraform.tfvars ${HOME}/pivotal*/terraforming-pks
cd ${HOME}/pivotal*/terraforming-pks

terraform init
terraform plan
terraform apply -auto-approve
