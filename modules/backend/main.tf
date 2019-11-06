resource "azurerm_resource_group" "group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.group.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "${var.replication_type}"

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.container_name}"
  storage_account_name  = "${azurerm_storage_account.sa.name}"
  container_access_type = "private"
}