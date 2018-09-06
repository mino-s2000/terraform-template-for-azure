variable "rg_name" {}
variable "location" {}
variable "nsg_name" {}

resource "azurerm_network_security_group" "nsg" {
  name = "${var.nsg_name}"
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"

  # rule sample
  security_rule {
    name = "RDP"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefixes = [
      "0.0.0.0"
    ]
    destination_port_range = "3389"
    destination_address_prefix = "VirtualNetwork"
  }
}

output "nsg_id" {
  value = "${azurerm_network_security_group.nsg.id}"
}
