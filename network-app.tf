resource "azurerm_public_ip" "pip-aula-app" {
  name                    = "pip-aula-app"
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg-aula.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula]
}

resource "azurerm_network_interface" "nic-aula-app" {
  name                = "nic-aula-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-aula.name

  ip_configuration {
    name                          = "nic-aula-app-config"
    subnet_id                     = azurerm_subnet.sub-aula.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.80.4.11"
    public_ip_address_id          = azurerm_public_ip.pip-aula-app.id
  }

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula, azurerm_subnet.sub-aula, azurerm_public_ip.pip-aula-app]
}

resource "azurerm_network_interface_security_group_association" "nic-nsq-aula-app" {
  network_interface_id      = azurerm_network_interface.nic-aula-app.id
  network_security_group_id = azurerm_network_security_group.nsg-aula.id

  depends_on = [azurerm_network_interface.nic-aula-app, azurerm_network_security_group.nsg-aula]
}
