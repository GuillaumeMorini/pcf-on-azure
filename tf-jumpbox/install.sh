#!/bin/bash

echo "Initializing Terraform"
terraform init || exit 1

echo "Running Terraform"
terraform apply -auto-approve || exit 1

JUMPBOX_IP=$(az vm list-ip-addresses -n jbox-pcf --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv)

echo ""
echo "You successfully bootstrapped the jumpbox on Azure and start installing PCF."
echo ""
echo "You can now initialize the installation process from the jumpbox:"
echo "  $ ssh ubuntu@$JUMPBOX_IP -i azurejumpbox_rsa"
echo "  $ cd /home/ubuntu/scripts"
echo "  $ ./init.sh"
