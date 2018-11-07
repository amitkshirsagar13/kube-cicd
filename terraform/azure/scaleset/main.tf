resource "azurerm_resource_group" "vmss" {
  name     = "vmss"
  location = "${var.location}"

  tags {
    environment = "terraform"
  }
}

resource "azurerm_virtual_network" "vmss" {
  name                = "vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"

  tags {
    environment = "terraform"
  }
}

resource "azurerm_subnet" "vmss" {
  name                 = "vmss-subnet"
  resource_group_name  = "${azurerm_resource_group.vmss.name}"
  virtual_network_name = "${azurerm_virtual_network.vmss.name}"
  address_prefix       = "10.0.7.0/24"
}

resource "azurerm_public_ip" "vmss" {
  name                         = "vmss-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vmss.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "k8cluster-${azurerm_resource_group.vmss.name}"

  tags {
    environment = "terraform"
  }
}

resource "azurerm_lb" "vmss" {
  name                = "vmss-lb"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.vmss.id}"
  }

  tags {
    environment = "terraform"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id     = "${azurerm_lb.vmss.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id     = "${azurerm_lb.vmss.id}"
  name                = "ssh-running-probe"
  port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id                = "${azurerm_lb.vmss.id}"
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = "${var.application_port}"
  backend_port                   = "${var.application_port}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = "${azurerm_lb_probe.vmss.id}"
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "location" {
  description = "Location"
  default     = "West US"
}

resource "azurerm_public_ip" "jumpbox" {
  name                         = "jumpbox-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vmss.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "k8cluster-${azurerm_resource_group.vmss.name}-ssh"

  tags {
    environment = "terraform"
  }
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "jumpbox-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = "${azurerm_subnet.vmss.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox.id}"
  }

  tags {
    environment = "terraform"
  }
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "jumpbox"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.vmss.name}"
  network_interface_ids = ["${azurerm_network_interface.jumpbox.id}"]
  vm_size               = "Standard_DS1"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  # plan {
  #   name      = "cis-oracle7-l1"
  #   publisher = "center-for-internet-security-inc"
  #   product   = "cis-oracle-linux-7-v2-0-0-l1"
  # }

  storage_os_disk {
    name              = "jumpbox-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "jumpbox"
    admin_username = "tadmin"
    admin_password = "Pass#123"
    custom_data    = "${file("web.conf")}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags {
    environment = "terraform"
  }
  provisioner "file" {
    source      = "base-setup.sh"
    destination = "/tmp/base-setup.sh"

    connection {
      type     = "ssh"
      user     = "tadmin"
      password = "Pass#123"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "echo Pass#123 |sudo -S chmod -x /tmp/base-setup.sh",
      "echo Pass#123 |sudo -S sh /tmp/base-setup.sh",
    ]

    # "echo Pass#123 |sudo -S chmod 777 /etc/sysctl.conf",
    # "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf",
    # "echo Pass#123 |sudo -S sysctl -p",
    # "echo Pass#123 |sudo -S firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o eth0 -j MASQUERADE",
    # "echo Pass#123 |sudo -S firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i eth1 -j ACCEPT",
    # "echo Pass#123 |sudo -S firewall-cmd --reload",

    connection {
      type     = "ssh"
      user     = "tadmin"
      password = "Pass#123"
    }
  }
}

output "jumpbox_public_ip" {
  value = "${azurerm_public_ip.jumpbox.fqdn}"
}

# data "azurerm_resource_group" "image" {
#   name = "myResourceGroup"
# }

# data "azurerm_image" "image" {
#   name                = "myPackerImage"
#   resource_group_name = "${data.azurerm_resource_group.image.name}"
# }

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "vmscaleset"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1"
    tier     = "Standard"
    capacity = 2
  }

  #   storage_profile_image_reference {
  #     id = "${data.azurerm_image.image.id}"
  #   }

  storage_profile_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }
  # plan {
  #   name      = "cis-oracle7-l1"
  #   publisher = "center-for-internet-security-inc"
  #   product   = "cis-oracle-linux-7-v2-0-0-l1"
  # }
  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }
  os_profile {
    computer_name_prefix = "terravmss"
    admin_username       = "tadmin"
    admin_password       = "Pass#123"
    custom_data          = "${file("web.conf")}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.vmss.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
    }
  }
  tags {
    environment = "terraform"
  }

  # provisioner "file" {
  #   source      = "base-setup.sh"
  #   destination = "/tmp/base-setup.sh"


  #   connection {
  #     type     = "ssh"
  #     user     = "tadmin"
  #     password = "Pass#123"


  #     bastion_host     = "${azurerm_public_ip.jumpbox.fqdn}"
  #     bastion_user     = "tadmin"
  #     bastion_password = "Pass#123"
  #   }
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo Pass#123 |sudo -S yum install -y yum-utils device-mapper-persistent-data lvm2",
  #     "echo Pass#123 |sudo -S yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
  #     "echo Pass#123 |sudo -S yum install -y docker-ce",
  #     "echo Pass#123 |sudo -S systemctl enable docker",
  #     "echo Pass#123 |sudo -S systemctl start docker",
  #   ]

  #   connection {
  #     type             = "ssh"
  #     host             = "${element(azurerm_lb_backend_address_pool.bpepool, count.index)}"
  #     user             = "tadmin"
  #     password         = "Pass#123"
  #     agent            = false
  #     bastion_host     = "${azurerm_public_ip.jumpbox.fqdn}"
  #     bastion_user     = "tadmin"
  #     bastion_password = "Pass#123"
  #     timeout          = "10s"
  #   }
  # }
  depends_on = ["azurerm_virtual_machine.jumpbox"]
}

resource "azurerm_autoscale_setting" "as" {
  name                = "myAutoscaleSetting"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  location            = "${azurerm_resource_group.vmss.location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.vmss.id}"

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.vmss.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.vmss.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["amit.kshirsagar.13@gmail.com"]
    }
  }
}
