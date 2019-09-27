#!/bin/bash

echo "Provisioning some Azure managed identities for PKS..."
echo "Retrieving the name of the resource group and the subscription ID..."
SUBSCRIPTION_ID=`(cat output.json | jq -r '.subscription_id.value')`
RESOURCE_GROUP=`(cat output.json | jq -r '.pcf_resource_group_name.value')`

cat > pks-master-role.json <<-EOF
{
    "Name":  "PKS master $RESOURCE_GROUP",
    "IsCustom":  true,
    "Description":  "Permissions for PKS master",
    "Actions":  [
        "Microsoft.Network/*",
        "Microsoft.Compute/disks/*",
        "Microsoft.Compute/virtualMachines/write",
        "Microsoft.Compute/virtualMachines/read",
        "Microsoft.Storage/storageAccounts/*"
    ],
    "NotActions":  [

    ],
    "DataActions":  [

    ],
    "NotDataActions":  [

    ],
    "AssignableScopes":  [
      "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
    ]
}
EOF

az role definition create --role-definition pks-master-role.json > pks-master-role-assigned.json
PKS_MASTER_ROLE_ID=`(cat pks-master-role-assigned.json | jq -r '.name')`
az identity create -g $RESOURCE_GROUP -n pks-master-$RESOURCE_GROUP > pks-master-identity-assigned.json
PKS_MASTER_IDENTIY=`(cat pks-master-identity-assigned.json | jq -r '.clientId')`

cat > pks-worker-role.json <<-EOF
{
    "Name":  "PKS worker $RESOURCE_GROUP",
    "IsCustom":  true,
    "Description":  "Permissions for PKS worker",
    "Actions":  [
        "Microsoft.Storage/storageAccounts/*"
    ],
    "NotActions":  [

    ],
    "DataActions":  [

    ],
    "NotDataActions":  [

    ],
    "AssignableScopes":  [
      "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
    ]
}
EOF

az role definition create --role-definition pks-worker-role.json > pks-worker-role-assigned.json
PKS_WORKER_ROLE_ID=`(cat pks-worker-role-assigned.json | jq -r '.name')`
az identity create -g $RESOURCE_GROUP -n pks-worker-$RESOURCE_GROUP > pks-worker-identity-assigned.json
PKS_WORKER_IDENTIY=`(cat pks-worker-identity-assigned.json | jq -r '.clientId')`

