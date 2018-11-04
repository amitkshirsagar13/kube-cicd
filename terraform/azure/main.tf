resource "azurerm_resource_group" "rg" {
  name     = "dev"
  location = "${var.rlocation}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "dev"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.rlocation}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  depends_on = ["azurerm_resource_group.rg"]
}

resource "azurerm_subnet" "dev" {
  name                 = "dev"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
  depends_on           = ["azurerm_resource_group.rg", "azurerm_virtual_network.vnet"]
}

resource "azurerm_lb" "lb" {
  name                = "dev_lb"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_public_ip" "dev" {
  name                         = "dev_public_ip"
  location                     = "${azurerm_resource_group.rg.location}"
  public_ip_address_allocation = "dynamic"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_group" "sg" {
  name                = "dev_security_group"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "out" {
  name                        = "out"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.sg.name}"
}

resource "azurerm_network_security_rule" "in" {
  name                        = "in"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.sg.name}"
}

resource "azurerm_network_interface" "nic" {
  name                      = "${azurerm_subnet.dev.name}-nic"
  location                  = "${var.rlocation}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "dev_a_configuration"
    private_ip_address_allocation = "static"
    subnet_id                     = "${azurerm_subnet.dev.id}"
    private_ip_address            = "10.0.1.11"
    public_ip_address_id          = "${azurerm_public_ip.dev.id}"
  }
}

# data "azurerm_resource_group" "image" {
#   name = "dev_images"
# }

# data "azurerm_image" "image" {
#   name                = "kong"
#   resource_group_name = "${data.azurerm_resource_group.image.name}"
# }

resource "azurerm_virtual_machine" "terravm" {
  name                  = "${var.rowner}-vm"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_DS1"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  # storage_image_reference {
  #   id = "${data.azurerm_image.image.id}"
  # }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  # plan{


  # }

  storage_os_disk {
    name              = "k8cluster"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8cluster"
    admin_username = "master"
    admin_password = "Pass#123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags {
    environment = "dev"
    owner       = "${var.rowner}"
  }
}
