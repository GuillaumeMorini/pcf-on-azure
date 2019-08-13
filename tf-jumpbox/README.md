# Jumpbox installation instructions

The installation of the jumpbox is based on Terraform. The main script performs two separate sets of actions:

- Creates an Azure AD application and Service Principal with the required access rights in order to proceed with the terraform configuration.
- Triggers the terraform deployment. This in turn performs three separate sets of actions:
   1. Creates and links Azure resources such as VM, Network Interface, Security Group, IP Address, etc.
   2. Performs a remote copy of the local /scripts folder into the /home/ubuntu/ folder. This folder is used to host all set of scripts that you may want to execute on the jumpbox.
   3. Triggers the remote execution of the init-jumpbox.sh script located in the /home/ubuntu/scripts folder.

## Prerequisites
In order to deploy the jumpbox on Azure, one needs:
1. a valid Azure subscription with administrator rights.
2. a sufficient quota in the region where the jumpbox will be deployed.
3. Azure CLI must be first installed locally.


## Installation

1. Log into Azure and set the correct subscription
   
        $ az login
        $ az account list
        $ az account set --subscription <subscription_name>

2. Assuming you are currently located in the top directory of `pcf-on-azure`, change directory to 'tf-jumpbox'.

        $ cd tf-jumpbox

3. Execute the `init.sh` script.

        $ ./init.sh

The script will request the following inputs:
- the name of the Jumpbox VM to create.
- the name of the Resource Group to place the resources into.
- the region where the resources will be deployed.

4. Log into the jumpbox
Once the Terraform script has been executed, you should see a new shell script called 'ssh-jumpbox.sh'. This script has been automatically generated with the output the Terraform script (including the dynamic IP address of the jumpbox).

You can log into the jumpbox VM using the following command:

        $ ./ssh-jumpbox.sh

## Reducing Azure consumption
You can reduce your Azure consumption by turning off your Jumpbox VM. This can be done easily by navigating to the Azure portal, and executing a "shutdown" of your VM.
Alternatively, you can schedule some automatic on/off of your VM so that it does not run while you don't need it (e.g. at night).

## Clean-up
In order to delete the Jumpbox VM and return to a known state, you need to execute two commands.

        $ terraform destroy
        $ ./tf-cleanup

The first command will delete all Azure jumpbox resources.
The second command will clean-up your folder, removing the terraform temporary files (vars and state), as well as the script used to log into the VM (the IP will be different the next time you create the jumpbox).

<strong>Note: The script currently does not remove the Service Principal and Application provisioned in Azure AD.<strong>



