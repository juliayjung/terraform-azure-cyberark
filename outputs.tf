output "storageaccount" {
  value = azurerm_storage_account.sa.id
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.vnet.id
}

output "test_subnet_id" {
  value = data.azurerm_subnet.test.id
}

output "public_ip_address" {
  value = data.azurerm_public_ip.pip.ip_address //module.terraweb.azurerm_public_ip_address
}

output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}

output "virtual_machine_id" {
  value = azurerm_virtual_machine.vm.id
}

//you will need to Deploy an Application Using Flux CD
output "host" {
  value     = module.app.cluster_fqdn
  sensitive = true
}

output "client_certificate" {
  value     = module.app.client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.app.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.app.cluster_ca_certificate
  sensitive = true
}