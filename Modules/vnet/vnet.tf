variable "rg_name" {}
variable "location" {}
variable "vnet_name" {}
variable "vnet_addr_space" {}

resource "azurerm_virtual_network" "vnet" {
  name = "${var.vnet_name}"
  address_space = ["${var.vnet_addr_space}"]
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"
}
