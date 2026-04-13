output "rg_name" {
  value = azurerm_resource_group.rg.name
}
output "location" {
  value = azurerm_resource_group.rg.location
}

output "tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
}

output "current_object_id" {
  value       = data.azurerm_client_config.current.object_id
}

output "current_user_principal_name" {
  value = data.azuread_user.current_user.user_principal_name
}