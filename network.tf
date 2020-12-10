resource "azurerm_virtual_network" "vnet_aula" {
    name                = "myVnet"
    address_space       = ["10.80.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_aula.name

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rg_aula ]
}

resource "azurerm_subnet" "subnet_aula" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rg_aula.name
    virtual_network_name = azurerm_virtual_network.vnet_aula.name
    address_prefixes       = ["10.80.4.0/24"]

    depends_on = [ azurerm_resource_group.rg_aula, azurerm_virtual_network.vnet_aula ]
}

resource "azurerm_public_ip" "publicip_aula" {
    name                         = "myPublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg_aula.name
    allocation_method            = "Static"
    idle_timeout_in_minutes = 30

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rg_aula ]
}

resource "azurerm_network_security_group" "sg_aula" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_aula.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPInbound"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPOutbound"
        priority                   = 1003
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rg_aula ]
}

resource "azurerm_network_interface" "nic_aula" {
    name                      = "myNIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg_aula.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.subnet_aula.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.80.4.11"
        public_ip_address_id          = azurerm_public_ip.publicip_aula.id
    }

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rg_aula, azurerm_subnet.subnet_aula, azurerm_public_ip.publicip_aula ]
}

resource "azurerm_network_interface_security_group_association" "nicsq_aula" {
    network_interface_id      = azurerm_network_interface.nic_aula.id
    network_security_group_id = azurerm_network_security_group.sg_aula.id

    depends_on = [ azurerm_network_interface.nic_aula, azurerm_network_security_group.sg_aula ]
}

data "azurerm_public_ip" "ip_aula_data" {
  name                = azurerm_public_ip.publicip_aula.name
  resource_group_name = azurerm_resource_group.rg_aula.name
}