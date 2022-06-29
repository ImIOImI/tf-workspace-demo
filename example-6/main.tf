terraform {
}

locals {
  subnet-compute = cidrsubnet(local.subnet,  4, 0)
  subnet-data    = cidrsubnet(local.subnet,  4, 0)
}

provider "azurerm" {
  features {}
  subscription_id = ""
}

resource "azurerm_resource_group" "rg" {
  location = local.location
  name     = "${local.workspace}-resource-group"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [local.subnet]
  location            = local.location
  name                = "${local.workspace}-subnet"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "compute-subnet" {
  address_prefixes     = [local.subnet-compute]
  name                 = "${local.workspace}-compute"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "data-subnet" {
  address_prefixes     = [local.subnet-data]
  name                 = "${local.workspace}-data"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_network_interface" "main" {
  name                = "${local.workspace}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.compute-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "compute" {
  name                  = "${local.workspace}-vm"
  location              = local.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = local.environment
  }
}