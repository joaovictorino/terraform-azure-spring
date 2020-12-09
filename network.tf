resource "azurerm_virtual_network" "vnetAula" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rgAula.name

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rgAula ]
}

resource "azurerm_subnet" "subnetAula" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rgAula.name
    virtual_network_name = azurerm_virtual_network.vnetAula.name
    address_prefixes       = ["10.0.1.0/24"]

    depends_on = [ azurerm_resource_group.rgAula, azurerm_virtual_network.vnetAula ]
}

resource "azurerm_public_ip" "publicipAula" {
    name                         = "myPublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rgAula.name
    allocation_method            = "Dynamic"
    idle_timeout_in_minutes = 30

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rgAula ]
}

resource "azurerm_network_security_group" "sgAula" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.rgAula.name

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

    depends_on = [ azurerm_resource_group.rgAula ]
}

resource "azurerm_network_interface" "nicAula" {
    name                      = "myNIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rgAula.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.subnetAula.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicipAula.id
    }

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rgAula, azurerm_subnet.subnetAula, azurerm_public_ip.publicipAula ]
}

resource "azurerm_network_interface_security_group_association" "nicsqAula" {
    network_interface_id      = azurerm_network_interface.nicAula.id
    network_security_group_id = azurerm_network_security_group.sgAula.id

    depends_on = [ azurerm_network_interface.nicAula, azurerm_network_security_group.sgAula ]
}