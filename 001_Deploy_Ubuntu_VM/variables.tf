variable "azure_service_principal" {
  type = "map"

  default = {
    subscription_id = ""
    client_id       = ""
    client_secret   = ""
    tenant_id       = ""
  }
}

variable "resource_name_prefix" {
  default = "Sample"
}

variable "resource_group" {
  type = "map"

  default = {
    name_suffix = "RG"
    location    = "japaneast"
  }
}

variable "vnet" {
  type = "map"

  default = {
    name_suffix = "Net"
    addr_space  = "10.0.0.0/16"
  }
}

variable "subnet" {
  type = "map"

  default = {
    name_suffix = "Subnet"
    addr_space  = "10.0.0.0/24"
  }
}

variable "nsg" {
  type = "map"

  default = {
    name_suffix = "NSG"
  }
}

variable "vm" {
  type = "map"

  default = {
    name           = "VM01"
    size           = "Standard_A1_v2"
    admin_username = "azureuser"
    ssh_key_data   = ""
  }
}

locals {
  rg_name = "${format("%s%s", var.resource_name_prefix, var.resource_group["name_suffix"])}"

  vnet_name   = "${format("%s%s", var.resource_name_prefix, var.vnet["name_suffix"])}"
  subnet_name = "${format("%s%s", var.resource_name_prefix, var.subnet["name_suffix"])}"

  nsg_name = "${format("%s%s", var.resource_name_prefix, var.nsg["name_suffix"])}"

  vm_pip_name                  = "${format("%sPIP", var.vm["name"])}"
  vm_pip_domain_name           = "${format("%s-%s", lower(var.resource_name_prefix), lower(var.vm["name"]))}"
  vm_nic_name                  = "${format("%sNic", var.vm["name"])}"
  vm_diag_storage_account_name = "${format("%s%sdiag", lower(var.resource_name_prefix), lower(var.vm["name"]))}"
}
