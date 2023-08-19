resource "azurerm_resource_group" "rg_adds" {
  location = var.resource_group_location
  name     = "rg_adds4"
}

resource "azurerm_virtual_network" "adds_network" {
  name                = "adds-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_adds.location
  resource_group_name = azurerm_resource_group.rg_adds.name
}

resource "azurerm_subnet" "adds_subnet" {
  name                 = "adds-subnet"
  resource_group_name  = azurerm_resource_group.rg_adds.name
  virtual_network_name = azurerm_virtual_network.adds_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "adds_public_ip" {
  name                = "adds-public-ip"
  location            = azurerm_resource_group.rg_adds.location
  resource_group_name = azurerm_resource_group.rg_adds.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "adds_nsg" {
  name                = "adds-nsg"
  location            = azurerm_resource_group.rg_adds.location
  resource_group_name = azurerm_resource_group.rg_adds.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface" "adds_nic" {
  name                = "adds-nic"
  location            = azurerm_resource_group.rg_adds.location
  resource_group_name = azurerm_resource_group.rg_adds.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.adds_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.adds_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.adds_nic.id
  network_security_group_id = azurerm_network_security_group.adds_nsg.id
}


resource "azurerm_windows_virtual_machine" "adds_vm" {
  name                  = "adds-vm2"
  admin_username        = "chicano"
  admin_password        = "RomaLocuta123@"
  location              = azurerm_resource_group.rg_adds.location
  resource_group_name   = azurerm_resource_group.rg_adds.name
  network_interface_ids = [azurerm_network_interface.adds_nic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
     name                 = "adds-disk2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


}


resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.rg_adds.name
  }

  byte_length = 8
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}
