# ACR with Private Endpoint
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
  public_network_access_enabled = false
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = var.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "acr-dns-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = var.vnet_id                    
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "acr" {
  name                = "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id         

  private_service_connection {
    name                           = "acr-private-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.acr
  ]
}