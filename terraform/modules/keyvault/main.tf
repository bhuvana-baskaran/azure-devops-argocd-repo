# Key Vault with Private Endpoint
resource "azurerm_key_vault" "kv" {
  name                = var.kv_name
  location            = var.location
  resource_group_name = var.rg_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  purge_protection_enabled = true

  rbac_authorization_enabled     = true
  public_network_access_enabled = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices" 
  }
}

resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = "aks-workload-identity"
  resource_group_name = var.rg_name
  location            = var.location
}


# Assign Key Vault Secrets User role to workload identity
resource "azurerm_role_assignment" "kv_access" {
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.kv.id
}

resource "azurerm_federated_identity_credential" "workload_fic" {
  name                      = "fic-aks-workload"
  user_assigned_identity_id = azurerm_user_assigned_identity.workload_identity.id
  issuer                    = var.issuer
  subject                   = "system:serviceaccount:${var.app_namespace}:${var.app_name}-sa"
  audience                  = ["api://AzureADTokenExchange"]
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name =  var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-dns-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${var.kv_name}-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "kv-privatesc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.keyvault
  ]
}