resource "azurerm_resource_group" "rg" {
  name     = "dev"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "devVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags       = "${var.tagOwner}"
  depends_on = ["azurerm_resource_group.rg"]
}

resource "azurerm_subnet" "dev" {
  name                 = "devSubnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
  depends_on           = ["azurerm_resource_group.rg", "azurerm_virtual_network.vnet"]
}

resource "azurerm_network_interface" "nic" {
  name                = "${azurerm_subnet.dev.name}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "dev_a_configuration"
    private_ip_address_allocation = "static"
    subnet_id                     = "${azurerm_subnet.dev.id}"
    private_ip_address            = "10.0.1.2"
  }
}

data "azurerm_resource_group" "image" {
  name = "dev_images"
}

data "azurerm_image" "image" {
  name                = "kong"
  resource_group_name = "${data.azurerm_resource_group.image.name}"
}

resource "azurerm_virtual_machine" "next_edge" {
  name                  = "${var.owner}-vm"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.image.id}"
  }

  #   storage_image_reference {
  #     publisher = "OpenLogic"
  #     offer = "CentOS"
  #     sku = "7.3"
  #     version = "latest"
  #   }

  storage_os_disk {
    name              = "kong_root"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "kong"
    admin_username = "terradmin"
    admin_password = "Pass#123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags {
    environment = "dev"
    owner       = "${var.owner}"
  }
}
