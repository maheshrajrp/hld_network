terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "env" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "env" {
  name                = "${var.prefix}-vnet"
  address_space       = var.default_vnet_address_space
  location            = azurerm_resource_group.env.location
  resource_group_name = azurerm_resource_group.env.name
}

resource "azurerm_subnet" "env" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.env.name
  virtual_network_name = azurerm_virtual_network.env.name
  address_prefixes     = var.default_subnet_address_space
}

resource "azurerm_network_security_group" "env" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.env.name
  location            = azurerm_resource_group.env.location
}

resource "azurerm_subnet_network_security_group_association" "env" {
  subnet_id                 = azurerm_subnet.env.id
  network_security_group_id = azurerm_network_security_group.env.id
}

resource "azurerm_public_ip" "env" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.env.name
  location            = azurerm_resource_group.env.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "env" {
  name = "${var.prefix}-nic"
  ip_configuration {
    name                          = "${var.prefix}-nic-ip-config"
    subnet_id                     = azurerm_subnet.env.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.env.id
  }
  resource_group_name = azurerm_resource_group.env.name
  location            = azurerm_resource_group.env.location
}

resource "azurerm_network_interface_security_group_association" "env" {
  network_interface_id      = azurerm_network_interface.env.id
  network_security_group_id = azurerm_network_security_group.env.id
}

resource "azurerm_network_security_rule" "env" {
  resource_group_name         = azurerm_resource_group.env.name
  network_security_group_name = azurerm_network_security_group.env.name
  name                        = "Allow_SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_virtual_machine" "env" {
  name                             = "${var.prefix}-env-vm"
  location                         = azurerm_resource_group.env.location
  resource_group_name              = azurerm_resource_group.env.name
  network_interface_ids            = [azurerm_network_interface.env.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}
