variable "rg_name" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "subnet_address_prefix" {}
variable "nsg_id" {}

resource "azurerm_subnet" "subnet" {
  name = "${var.subnet_name}"
  resource_group_name = "${var.rg_name}"
  virtual_network_name = "${var.vnet_name}"
  address_prefix = "${var.subnet_address_prefix}"
  network_security_group_id = "${var.nsg_id}"
}

output "subnet_id" {
  value = "${azurerm_subnet.subnet.id}"
}
