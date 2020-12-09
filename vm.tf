resource "azurerm_resource_group" "rgAula" {
    name     = "myResourceGroup"
    location = var.location

    tags = {
        environment = "aula infra"
    }
}

resource "azurerm_storage_account" "storageAula" {
    name                        = "storageaula2"
    resource_group_name         = azurerm_resource_group.rgAula.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rgAula ]
}

resource "azurerm_linux_virtual_machine" "vmAula" {
    name                  = "myVM"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rgAula.name
    network_interface_ids = [azurerm_network_interface.nicAula.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageAula.primary_blob_endpoint
    }

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rgAula, azurerm_network_interface.nicAula, azurerm_storage_account.storageAula, azurerm_public_ip.publicipAula ]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_linux_virtual_machine.vmAula]
  create_duration = "30s"
}

resource "null_resource" "upload" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = azurerm_public_ip.publicipAula.ip_address
        }
        source = "springapp/springapp.zip"
        destination = "/home/azureuser/springapp.zip"
    }

    depends_on = [ time_sleep.wait_30_seconds ]
}

resource "null_resource" "deploy" {
    triggers = {
        order = null_resource.upload.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = azurerm_public_ip.publicipAula.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y openjdk-11-jre unzip",
            "mkdir /home/azureuser/springapp",
            "rm -rf /home/azureuser/springapp/*.*",
            "unzip -o /home/azureuser/springapp.zip -d /home/azureuser/springapp",
            "nohup java -jar /home/azureuser/springapp/*.jar &",
            "sleep 20",
        ]
    }
}

resource "null_resource" "run" {
    triggers = {
        order = null_resource.deploy.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = azurerm_public_ip.publicipAula.ip_address
        }
        inline = [
            "java -jar /home/azureuser/springapp/*.jar &",
        ]
    }
}