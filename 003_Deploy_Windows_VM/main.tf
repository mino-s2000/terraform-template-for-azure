provider "azurerm" {
  subscription_id = "${var.azure_service_principal["subscription_id"]}"
  client_id = "${var.azure_service_principal["client_id"]}"
  client_secret = "${var.azure_service_principal["client_secret"]}"
  tenant_id = "${var.azure_service_principal["tenant_id"]}"
}

module "resource_group" {
  source = "./modules/resource_group"

  rg_name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
}

module "nsg" {
  source = "./modules/nsg"

  rg_name = "${local.nsg_name}"
  location = "${var.resource_group["location"]}"
  nsg_name = "${local.nsg_name}"
}

module "vnet" {
  source = "./modules/vnet"

  rg_name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
  vnet_name = "${local.vnet_name}"
  vnet_addr_space = "${var.vnet["addr_space"]}"
}

module "subnet" {
  source = "./modules/subnet"

  rg_name = "${local.rg_name}"
  vnet_name = "${local.vnet_name}"
  subnet_name = "${local.subnet_name}"
  subnet_address_prefix = "${var.subnet["addr_space"]}"
  nsg_id = "${module.nsg.nsg_id}"
}

module "pip" {
  source = "./modules/public_ip"

  rg_name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
  pip_name = "${local.vm_pip_name}"
  pip_domain_name = "${local.vm_pip_domain_name}"
}

module "nic" {
  source = "./modules/nic"

  rg_name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
  nic_name = "${local.vm_nic_name}"
  nic_private_ip_addr = "${var.vm["addr"]}"
  subnet_id = "${module.subnet.subnet_id}"
  pip_id = "${module.pip.pip_id}"
}

module "storage_vm_diag" {
  source = "./modules/storage"

  rg_name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
  storage_account_name = "${local.vm_diag_storage_account_name}"
}

module "vm" {
  source = "./modules/centos_vm"

  rg_name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
  vm_name = "${var.vm["name"]}"
  vm_size = "${var.vm["size"]}"
  nic_id = "${module.nic.nic_id}"
  admin_username = "${var.vm["admin_username"]}"
  admin_password = "${var.vm["admin_password"]}"
  blob_endpoint = "${module.storage_vm_diag.primary_blob_endpoint}"
}
