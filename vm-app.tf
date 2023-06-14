resource "azurerm_linux_virtual_machine" "vm-aula-app" {
  name                  = "vm-aula-app"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-aula.name
  network_interface_ids = [azurerm_network_interface.nic-aula-app.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "disk-aula-app"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "vm-aula-app"
  admin_username                  = var.user
  admin_password                  = var.password
  disable_password_authentication = false

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula, azurerm_network_interface.nic-aula-app, azurerm_public_ip.pip-aula-app]
}

resource "null_resource" "upload-app" {
  provisioner "file" {
    connection {
      type     = "ssh"
      user     = var.user
      password = var.password
      host     = azurerm_public_ip.pip-aula-app.ip_address
    }
    source      = "springapp"
    destination = "/home/${var.user}"
  }

  depends_on = [azurerm_linux_virtual_machine.vm-aula-app]
}

resource "null_resource" "deploy" {
  triggers = {
    order = null_resource.upload-app.id
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.user
      password = var.password
      host     = azurerm_public_ip.pip-aula-app.ip_address
    }
    inline = [
      "chmod 777 ./springapp/install.sh",
      "./springapp/install.sh"
    ]
  }
}
