resource "azurerm_resource_group" "k8s" {
  name     = "${var.prefix}-aks-${var.region}-${var.environment}-${var.location_key}-group"
  location = "${var.location}"
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "k8s" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "k8s-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = "${azurerm_resource_group.k8s.location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    sku                 = "Standalone"
}

resource "azurerm_log_analytics_solution" "k8s" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_resource_group.k8s.location}"
    resource_group_name   = "${azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.k8s.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.k8s.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}-aks-${var.region}-${var.environment}-${var.location_key}"
  location            = "${var.location}"
  dns_prefix          = "${var.prefix}-aks-${var.region}-${var.environment}-${var.location_key}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  kubernetes_version  = "${var.kubernetes_version}"

  linux_profile {
    admin_username = "${var.AZURE_AKS_ADMIN_USER}"

    ssh_key {
      key_data = "${var.PUBLIC_SSH_KEY}"
    }
  }

  agent_pool_profile {
    name            = "agentpool"
    count           = "${var.vm_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30

    # Required for advanced networking
    vnet_subnet_id = "${var.vnet_subnet_id}"
  }

  service_principal {
    client_id     = "${var.AZURE_CLIENT_ID}"
    client_secret = "${var.AZURE_CLIENT_SECRET}"
  }
    
  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true
        azure_active_directory {
            server_app_id         = "${var.AZURE_AKS_AAD_SERVER_APP_ID}"
            server_app_secret     = "${var.AZURE_AKS_AAD_SERVER_SECRET}"
            client_app_id         = "${var.AZURE_AKS_AAD_CLIENT_APP_ID}"
            tenant_id             = "${var.AZURE_TENANT_ID}"
        }
  }

  addon_profile {
    oms_agent {
      enabled                     = true
      log_analytics_workspace_id  = "${azurerm_log_analytics_workspace.k8s.id}"
    }
  }
}

output "aks_resource_group" {
  value = "${azurerm_resource_group.k8s.name}"
}

output "aks_name" {
  value = "${azurerm_kubernetes_cluster.k8s.name}"
}
  