output "storageaccount" {
  value = azurerm_storage_account.sa.id
}

output "vnet" {
  value = data.azurerm_virtual_network.vnet.id
}

output "test_subnet" {
  value = data.azurerm_subnet.test.id
}

output "public_ip" {
  value = data.azurerm_public_ip.pip.ip_address //module.terraweb.azurerm_public_ip_address
}

output "nic" {
  value = azurerm_network_interface.nic.name
}

output "virtual_machine" {
  value = azurerm_virtual_machine.vm.name
}