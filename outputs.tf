output "storageaccount" {
  value = azurerm_storage_account.storageaccount.name
}

output "app_subnet_id" {
  value = data.azurerm_subnet.default.id
}

output "public_ip" {
  value = module.terraweb.azurerm_public_ip_address
}