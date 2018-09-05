variable "rg_name" {}
variable "location" {}
variable "vm_name" {}
variable "vm_size" {}
variable "nic_id" {}
variable "admin_username" {}
variable "ssh_key_data" {}
variable "blob_endpoint" {}

resource "azurerm_virtual_machine" "centos_vm" {
  name = "${var.vm_name}"
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"
  vm_size = "${var.vm_size}"
  network_interface_ids = ["${var.nic_id}"]

  storage_image_reference {
    publisher = "OpenLogic"
    offer = "CentOS"
    sku = "7.5"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.vm_name}-OS"
    managed_disk_type = "Standard_LRS"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "${var.vm_name}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.ssh_key_data}"
    }
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${var.blob_endpoint}"
  }
}
