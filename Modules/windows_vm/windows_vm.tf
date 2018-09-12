variable "rg_name" {}
variable "location" {}
variable "vm_name" {}
variable "vm_size" {}
variable "nic_id" {}
variable "admin_username" {}
variable "admin_password" {}
variable "blob_endpoint" {}

resource "azurerm_virtual_machine" "win_vm" {
  name                  = "${var.vm_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.rg_name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${var.nic_id}"]

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${format("%s-OS", var.vm_name)}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${var.blob_endpoint}"
  }
}
