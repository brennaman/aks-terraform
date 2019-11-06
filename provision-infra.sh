#!/usr/bin/env bash

while getopts u:p:t: option
do
case "${option}"
in
u) USERNAME=${OPTARG};;
p) PASSWORD=${OPTARG};;
t) TENANT=${OPTARG};;
esac
done

terraform workspace new infra setup
terraform workspace select infra setup

# create backend and aks infrastructure
terraform init -input=false setup
terraform apply -var-file=backend.tfvars -auto-approve setup

RESOURCE_GROUP=$(terraform output aks_resource_group)
CLUSTER_NAME=$(terraform output aks_name)

# migrate local state to the remote backend [s3, consul, azure storage account, etc.]
echo "yes" | terraform init -backend-config=backend.tfvars infra

az login --service-principal --username $USERNAME --password $PASSWORD --tenant $TENANT
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing --admin

# run terraform to configure k8s
cd cluster

terraform init -input=false

terraform apply -auto-approve