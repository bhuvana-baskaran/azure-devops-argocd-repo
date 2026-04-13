module "rg" {
  source   = "./modules/resource_group"
  rg_name  = var.rg_name
  location = var.location
}

module "network" {
  source                    = "./modules/network"
  rg_name                   = module.rg.rg_name
  location                  = module.rg.location
  vnet_name                 = var.vnet_name
  subnet_name               = var.subnet_name
  address_space             = var.address_space
  aks_subnet_prefix         = var.aks_subnet_prefix
}

module "aks" {
  source              = "./modules/aks"
  aks_name            = var.aks_name
  location            = module.rg.location
  rg_name             = module.rg.rg_name
  dns_prefix          = var.dns_prefix
  subnet_id           = module.network.aks_subnet_id
  k8s_version         = var.k8s_version
  tenant_id           = module.rg.tenant_id
  current_object_id   = module.rg.current_object_id
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  rg_name             = module.rg.rg_name
  location            = module.rg.location
  vnet_id             = module.network.aks_vnet_id
  subnet_id           = module.network.aks_subnet_id
  principal_id        = module.aks.kubelet_identity_object_id
}

module "keyvault" {
  source              = "./modules/keyvault"
  kv_name             = var.kv_name
  rg_name             = module.rg.rg_name
  location            = module.rg.location
  vnet_id             = module.network.aks_vnet_id
  subnet_id           = module.network.aks_subnet_id
  issuer              = module.aks.oidc_issuer_url
  tenant_id           = module.rg.tenant_id
  app_name            = var.app_name
  app_namespace       = var.app_namespace
}
