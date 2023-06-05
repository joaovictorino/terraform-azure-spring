resource "random_string" "random_vm" {
  length  = 20
  upper   = false
  special = false
}

resource "azurerm_storage_account" "sa-aula-app" {
  name                     = "app${random_string.random_vm.result}"
  resource_group_name      = azurerm_resource_group.rg-aula.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula]
}

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

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sa-aula-app.primary_blob_endpoint
  }

  tags = {
    environment = "aula infra"
  }

  depends_on = [azurerm_resource_group.rg-aula, azurerm_network_interface.nic-aula-app, azurerm_storage_account.sa-aula-app, azurerm_public_ip.pip-aula-app]
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
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-11-jre unzip",
      "mkdir /home/azureuser/springmvcapp",
      "rm -rf /home/azureuser/springmvcapp/*.*",
      "unzip -o /home/azureuser/springapp/springapp.zip -d /home/azureuser/springmvcapp",
      "sudo mkdir -p /var/log/springapp",
      "sudo cp /home/azureuser/springapp/springapp.service /etc/systemd/system/springapp.service",
      "sudo systemctl start springapp.service",
      "sudo systemctl enable springapp.service"
    ]
  }
}
