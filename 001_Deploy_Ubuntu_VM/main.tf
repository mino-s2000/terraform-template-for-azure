provider "azurerm" {
  subscription_id = "${var.azure_service_principal["subscription_id"]}"
  client_id = "${var.azure_service_principal["client_id"]}"
  client_secret = "${var.azure_service_principal["client_secret"]}"
  tenant_id = "${var.azure_service_principal["tenant_id"]}"
}

resource "azurerm_resource_group" "rg" {
  name = "${local.rg_name}"
  location = "${var.resource_group["location"]}"
}

resource "azurerm_network_security_group" "nsg" {
  name = "${local.nsg_name}"
  location = "${var.resource_group["location"]}"
  resource_group_name = "${local.rg_name}"

  # rule sample
  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefixes = [
      "0.0.0.0"
    ]
    destination_port_range = "22"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name = "${local.vnet_name}"
  address_space = ["${var.vnet["addr_space"]}"]
  location = "${var.resource_group["location"]}"
  resource_group_name = "${local.rg_name}"
}

resource "azurerm_subnet" "subnet" {
  name = "${local.subnet_name}"
  resource_group_name = "${local.rg_name}"
  virtual_network_name = "${local.vnet_name}"
  address_prefix = "${var.subnet["addr_space"]}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_public_ip" "pip" {
  name = "${local.vm_pip_name}"
  location = "${var.resource_group["location"]}"
  resource_group_name = "${local.rg_name}"
  public_ip_address_allocation = "Static"
  domain_name_label = "${local.vm_pip_domain_name}"
}

resource "azurerm_network_interface" "nic" {
  name = "${local.vm_nic_name}"
  location = "${var.resource_group["location"]}"
  resource_group_name = "${local.rg_name}"

  ip_configuration {
    name = "${format("%sipconfig", local.vm_nic_name)}"
    subnet_id = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_storage_account" "storage" {
  name = "${local.vm_diag_storage_account_name}"
  location = "${var.resource_group["location"]}"
  resource_group_name = "${local.rg_name}"
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "ubuntu_vm" {
  name = "${var.vm["name"]}"
  location = "${var.resource_group["location"]}"
  resource_group_name = "${local.rg_name}"
  vm_size = "${var.vm["size"]}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${format("%s-OS", var.vm["name"])}"
    managed_disk_type = "Standard_LRS"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "${var.vm["name"]}"
    admin_username = "${var.vm["admin_username"]}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "${format("/home/%s/.ssh/authorized_keys", var.vm["admin_username"])}"
      key_data = "${var.vm["ssh_key_data"]}"
    }
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${azurerm_storage_account.storage.primary_blob_endpoint}"
  }
}
