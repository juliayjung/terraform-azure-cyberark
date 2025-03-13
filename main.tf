resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_id

  //3 tags are required
  tags = {
    Owner      = "Jung, Julia"
    Department = "dsoa"
    Project    = "cyberark-terraform"
  }
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "strg${random_string.uniquestring.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
