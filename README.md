# pcf-on-azure

This set of scripts attempts to automate the deployment of PCF (PAS + PKS) on Azure.

The first proposed step is to deploy a jumpbox in a chosen Resource Group, with all the tools and scripts required to install PCF. Instructions for installing the jumpbox are provided [here](https://github.com/npintaux/pcf-on-azure/tree/master/tf-jumpbox "Jumpbox installation instructions").

## Installing PCF on Azure
The following instructions must be run on the Jumpbox. If its deployment has been successful, you should see a <code>/script</code> folder. This folder contains a numbered list of scripts that will be used to deploy all tiles.

### Login to Azure
Once you are logged onto the jumpbox, you are running as "ubuntu", i.e. the admin. You have therefore not yet logged into Azure yet.
To proceed, type

        $ az login

and proceed to `https://aka.ms/devicelogin` to enter your device code.

### Preparing the terraform files
From the {HOME} directory, proceed with the following commands:

        $ cd scripts
        $ ./1-init.sh

This script will request a few information to download the Azure terraform package and build a terraform.tfvars file.

<note>
Note: At the time of this writing, we use the following versions:
    OpsMan: 2.6.6
    PAS: 2.6.2
    PKS: 1.5.0
    Harbor: 1.7.5
</note>

Once the Terraform files are unzipped, you will need to modify the version of the Azure Resource Provider:

        $ cd ../pivotal-cf-*
        $ cd terraforming-pas
        $ vi main.tf

        Replace the Azure provider section with the following (we set the version number to 1.31.0):

        provider "azurerm" {
            subscription_id = "${var.subscription_id}"
            client_id       = "${var.client_id}"
            client_secret   = "${var.client_secret}"
            tenant_id       = "${var.tenant_id}"
            environment     = "${var.cloud_name}"

            version = "1.31.0"
        }
This change is necessary to work with the versions mentioned above.

### Paving the environment for PAS and PKS
Paving the environment requires two steps: the first step is about paving for PAS using the Terraform scripts previously downloaded, and deploying Opsman. The second step is about creating the appropriate subnects for PKS. Both steps are performed by the following script:

        $ cd ~/scripts
        $ ./2-deploy-opsman.sh

At the end of the script, you will need be requested to register NS records in your DNS registrar in order to delegate DNS resolution to a DNS Zone in Azure.

### Configuring the BOSH Director
The configuration of the BOSH Director can actually be completely automated based on the output of the Terraform script. This is performed by the following script:

        $ cd ~/scripts
        $ ./3-configure-director.sh

At the end of the script, a first "Apply Changes" is triggered.

If you deployed a version of OpsMan different than 2.6.6 (as proposed here), you can create your own director configuration file by running the following script:

        $ ./create-director-config.sh

### Installing the PAS, PKS and Harbor tiles
One of the advantages of running those scripts from the Jumpbox is that the data transfer from the Jumpbox to the Opsman will be a lot faster than when running from your local machine.
A single script downloads the appropriate tile versions, uploads them to Ops Manager, and stages them.

        $ ./4-install-tiles.sh









