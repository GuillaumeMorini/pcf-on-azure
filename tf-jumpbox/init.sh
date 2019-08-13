#!/bin/bash

echo
echo
echo "This script is preparing the terraform.tfvars file you will need to customize to deploy your jumpbox."
echo "Prerequisite: be logged into your Azure account. If you have not done so, please run the following commands first:"
echo "    az login"
echo "    az account list (to see which subscriptions are available)"
echo "    az account set --subscription <subscription_id> (to select the correct one)"
echo
echo "The script first create a SSH key, which will be stored as azurejumpbox_rsa and azurejumpbox_rsa.pub in the local folder."
echo "It then creates an application in the Azure AD, and creates a Service Principal."
echo

echo "Generating the SSH key pair to securely connect to the jumpbox..."
ssh-keygen -t rsa -b 2048 -C "ubuntu@azurejumpbox" -f azurejumpbox_rsa -P ""
SSH_PUBLIC_KEY=`cat azurejumpbox_rsa.pub`
echo
echo

read -p "Please input the name of the jumpbox: " JUMPBOX_NAME
read -p "Please input the name of the resource group for the jumpbox: " JUMPBOX_RG 
echo "Please select the region to deploy PCF: " 
select AZURE_REGION in "Australia East" "Australia Southeast" "Brazil South" "Canada Central" "Canada East" "Central India" "Central US" "East Asia" "East US" "East US 2" "France Central" "Japan East" "Japan West" "Korea Central" "Korea South" "North Central US" "North Europe" "South Central US" "South India" "Southeast Asia" "UK South" "UK West" "West Central US" "West Europe" "West India" "West US" "West US 2"
do
    break
done
AZURE_SUBSCRIPTION_ID=`az account show --query id`
AZURE_TENANT_ID=`az account show --query tenantId`
AZURE_ACCOUNT_NAME=`az account show --query name`
AZURE_APP_IDENTIFIER_URI=$(printf "http://BOSHAzureCPI-%s-%s" "${AZURE_ACCOUNT_NAME//\"/}" "$RANDOM")
AZURE_SP_PWD=$(printf "Pivotal-%s-%s" "${JUMPBOX_RG}" "$RANDOM")

echo "Initializing the Azure AD Application"
AZURE_CLIENT_SECRET="$AZURE_SP_PWD"
AZURE_CLIENT_ID=`az ad app create --display-name "Service Principal for jumpbox ${JUMPBOX_NAME}" \
	--password $AZURE_SP_PWD --homepage "http://BOSHAzureCPI" \
        --identifier-uris $AZURE_APP_IDENTIFIER_URI --query "appId"`

echo
echo "Initializing the Azure Service Principal"
AZURE_SP_OBJECT_ID=`az ad sp create --id $(printf "%s" "${AZURE_CLIENT_ID//\"/}") --query "objectId"`

echo "Waiting for 60 seconds to let the Service Principal propagate in Azure Active Directory..."
sleep 60 
    
AZURE_SCOPE=$(printf "/subscriptions/%s" "${AZURE_SUBSCRIPTION_ID//\"/}")
echo "Azure Scope: $AZURE_SCOPE"
az role assignment create --assignee-object-id $(printf "%s" "${AZURE_SP_OBJECT_ID//\"/}") \
        --role Contributor --scope $AZURE_SCOPE

echo
echo "Registering subscription with Storage service"
az provider register --namespace Microsoft.Storage

echo "Registering subscription with Network service"
az provider register --namespace Microsoft.Network

echo "Registering subscription with Compute service"
az provider register --namespace Microsoft.Compute

echo "Initializing Terraform variable files"
cat > "terraform.tfvars" <<-EOF
# Azure specific variables
subscription_id=$AZURE_SUBSCRIPTION_ID
tenant_id=$AZURE_TENANT_ID
client_id=$AZURE_CLIENT_ID
client_secret="${AZURE_CLIENT_SECRET}"

resource_group="${JUMPBOX_RG}"
jumpbox_name="${JUMPBOX_NAME}"
region="${AZURE_REGION}"
ssh_public_key="${SSH_PUBLIC_KEY}"
EOF

echo "Sleeping for 60 extra seconds to let the registrations propagate..."
sleep 60

# Let's terraform this Jumpbox!
#
echo "Initializing Terraform"
terraform init || exit 1

echo "Running Terraform"
terraform apply -auto-approve || exit 1

JUMPBOX_IP=`(terraform output -json | jq -r '.jumpbox_public_ip_address.value')`
cat > "ssh-jumpbox.sh" <<-EOF
#!/bin/bash

ssh ubuntu@${JUMPBOX_IP} -i azurejumpbox_rsa
EOF
chmod +x ssh-jumpbox.sh

echo ""
echo "You successfully bootstrapped the jumpbox on Azure and can now start installing PCF."
echo ""
echo "You can now initialize the installation process from the jumpbox:"
echo "  $ ./ssh-jumpbox.sh"
echo "  $ az login   (THIS IS IMPORTANT!!!)"
echo "  $ cd /home/ubuntu/scripts"
echo "  $ ./init.sh"


