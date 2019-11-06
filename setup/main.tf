provider "azurerm" {
  subscription_id               = "${var.AZURE_SUBSCRIPTION_ID}"
  tenant_id                     = "${var.AZURE_TENANT_ID}"
  client_id                     = "${var.AZURE_CLIENT_ID}"
  client_secret                 = "${var.AZURE_CLIENT_SECRET}"
}

module "backend" {
  source                        = "../modules/backend"

  prefix                        = "${var.prefix}"
  environment                   = "${var.environment}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  storage_account_name          = "${var.storage_account_name}"
  container_name                = "${var.container_name}"
  key                           = "${var.key}"
  replication_type              = "${var.replication_type}"
  
}

module "k8s_cluster" {
  source                        = "../modules/aks"
  AZURE_CLIENT_ID               = "${var.AZURE_CLIENT_ID}"
  AZURE_CLIENT_SECRET           = "${var.AZURE_CLIENT_SECRET}"
  PUBLIC_SSH_KEY                = "${var.PUBLIC_SSH_KEY}"
  AZURE_AKS_ADMIN_USER          = "${var.AZURE_AKS_ADMIN_USER}"
  prefix                        = "${var.prefix}"
  environment                   = "${var.environment}"
  region                        = "${var.region}"
  location_key                  = "${var.location_key}"
  location                      = "${var.location}"
  vm_size                       = "${var.vm_size}"
  vm_count                      = "${var.vm_count}"
  kubernetes_version            = "${var.kubernetes_version}"
  vnet_subnet_id                = "${azurerm_subnet.k8s_internal1_subnet.id}"
  AZURE_AKS_AAD_CLIENT_APP_ID   = "${var.AZURE_AKS_AAD_CLIENT_APP_ID}"
  AZURE_AKS_AAD_SERVER_APP_ID   = "${var.AZURE_AKS_AAD_SERVER_APP_ID}"
  AZURE_AKS_AAD_SERVER_SECRET   = "${var.AZURE_AKS_AAD_SERVER_SECRET}"
  AZURE_TENANT_ID               = "${var.AZURE_TENANT_ID}"
}

output "aks_resource_group" {
  value = "${module.k8s_cluster.aks_resource_group}"
}

output "aks_name" {
  value = "${module.k8s_cluster.aks_name}"
}