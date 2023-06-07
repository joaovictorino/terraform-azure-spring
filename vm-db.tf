resource "azurerm_linux_virtual_machine" "vm-aula-db" {
  name                  = "vm-aula-db"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-aula.name
  network_interface_ids = [azurerm_network_interface.nic-aula-db.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "disk-aula-db"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "vm-aula-db"
  admin_username                  = var.user
  admin_password                  = var.password
  disable_password_authentication = false

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula, azurerm_network_interface.nic-aula-db, azurerm_public_ip.pip-aula-db]
}

resource "null_resource" "upload-db" {
  provisioner "file" {
    connection {
      type     = "ssh"
      user     = var.user
      password = var.password
      host     = azurerm_public_ip.pip-aula-db.ip_address
    }
    source      = "mysql"
    destination = "/home/azureuser"
  }

  depends_on = [azurerm_linux_virtual_machine.vm-aula-db]
}

resource "null_resource" "deploy-db" {
  triggers = {
    order = null_resource.upload-db.id
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.user
      password = var.password
      host     = azurerm_public_ip.pip-aula-db.ip_address
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mysql-server-5.7",
      "sudo mysql < /home/azureuser/mysql/script/user.sql",
      "sudo mysql < /home/azureuser/mysql/script/schema.sql",
      "sudo mysql < /home/azureuser/mysql/script/data.sql",
      "sudo cp -f /home/azureuser/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
      "sudo service mysql restart",
      "sleep 20",
    ]
  }
}
