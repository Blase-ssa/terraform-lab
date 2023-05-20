terraform {

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default-rg" {
  name     = "test-lab-1"
  location = "northeurope"
  tags = {
    Environment = "test-lab-1"
  }
}
resource "azurerm_virtual_network" "default-network" {
  name                = "default-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default-rg.location
  resource_group_name = azurerm_resource_group.default-rg.name
}
resource "azurerm_subnet" "internal-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.default-rg.name
  virtual_network_name = azurerm_virtual_network.default-network.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "default-network" {
  name                = "default-network"
  location            = azurerm_resource_group.default-rg.location
  resource_group_name = azurerm_resource_group.default-rg.name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.internal-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                = "linux-1"
  resource_group_name = azurerm_resource_group.default-rg.name
  location            = azurerm_resource_group.default-rg.location
  size                = "Standard_D2as_v4"
  admin_username      = "blase"
  network_interface_ids = [
    azurerm_network_interface.default-network.id,
  ]

  admin_ssh_key {
    username   = "blase"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}