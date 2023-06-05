output "public_ip_address_app" {
  value = "http://${azurerm_public_ip.pip-aula-app.ip_address}:8080"
}
