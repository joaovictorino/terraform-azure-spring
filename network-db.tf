resource "azurerm_public_ip" "pip-aula-db" {
  name                    = "pip-aula-db"
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg-aula.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula]
}

resource "azurerm_network_interface" "nic-aula-db" {
  name                = "nic-aula-db"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-aula.name

  ip_configuration {
    name                          = "nic-aula-db-config"
    subnet_id                     = azurerm_subnet.sub-aula.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.80.4.10"
    public_ip_address_id          = azurerm_public_ip.pip-aula-db.id
  }

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula, azurerm_subnet.sub-aula]
}

resource "azurerm_network_interface_security_group_association" "nic-nsq-aula-db" {
  network_interface_id      = azurerm_network_interface.nic-aula-db.id
  network_security_group_id = azurerm_network_security_group.nsg-aula.id

  depends_on = [azurerm_network_interface.nic-aula-db, azurerm_network_security_group.nsg-aula]
}
