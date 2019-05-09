#!/bin/bash

##########################################################
# Jumpbox Toolset                                        #
#     This script initializes all the tools required to  #
#     operate Pivotal Cloud Foundry.                     #
##########################################################

# We first download all tools necessary to operate PCF
sudo apt-get update
sudo apt update --yes && \
sudo apt install --yes unzip && \
sudo apt install --yes jq && \
sudo apt install --yes build-essential && \
sudo apt install --yes ruby-dev && \
sudo gem install --no-ri --no-rdoc cf-uaac

# PCF CLI
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt-get update
sudo apt-get install cf-cli


# Terraform
wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && \
  unzip terraform.zip && \
  sudo mv terraform /usr/local/bin && \
  rm terraform.zip

# PCF OM CLI
wget -O om https://github.com/pivotal-cf/om/releases/download/1.0.0/om-linux && \
  chmod +x om && \
  sudo mv om /usr/local/bin/

# BOSH CLI
wget -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.5.0-linux-amd64 && \
  chmod +x bosh && \
  sudo mv bosh /usr/local/bin/

# BBR CLI
wget -O /tmp/bbr.tar https://github.com/cloudfoundry-incubator/bosh-backup-and-restore/releases/download/v1.5.1/bbr-1.5.1.tar && \
  tar xvC /tmp/ -f /tmp/bbr.tar && \
  sudo mv /tmp/releases/bbr /usr/local/bin/

# PivNet CLI
VERSION=0.0.58
wget -O pivnet https://github.com/pivotal-cf/pivnet-cli/releases/download/v${VERSION}/pivnet-linux-amd64-${VERSION} && \
  chmod +x pivnet && \
  sudo mv pivnet /usr/local/bin/

# Azure CLI
sudo apt-get install apt-transport-https lsb-release software-properties-common dirmngr -y
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
     --keyserver packages.microsoft.com \
     --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
sudo apt-get update
sudo apt-get install azure-cli

# let's make sure that our environment is still up-to-date
sudo apt-get upgrade --yes
sudo apt-get update --yes
sudo apt update --yes

# Download utility to generate a multi-domain cert
git clone https://github.com/npintaux/generate-multidomain-cert.git

