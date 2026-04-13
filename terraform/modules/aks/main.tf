# Private AKS Cluster with Azure RBAC
resource "azurerm_role_assignment" "aks_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.current_object_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                = "system"
    vm_size             = "Standard_D2s_v3"
    vnet_subnet_id      = var.subnet_id
    os_disk_size_gb     = 128
    auto_scaling_enabled = true
    min_count           = 1
    max_count           = 3
    orchestrator_version = var.k8s_version
  }

  identity {
    type = "SystemAssigned"
  }

  private_cluster_enabled = true
  local_account_disabled  = true
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = [var.current_object_id]
    azure_rbac_enabled     = true                           
  }

  oidc_issuer_enabled = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = "10.0.2.10"
    service_cidr      = "10.0.2.0/24"
  }
}

# Additional user node pool
# resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
#   name                  = "userpool"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
#   vm_size               = "Standard_D2s_v3"
#   vnet_subnet_id        = var.subnet_id
#   os_disk_size_gb       = 200
#   auto_scaling_enabled =  true
#   min_count             = 1
#   max_count             = 5
#   orchestrator_version  = var.k8s_version
# }


