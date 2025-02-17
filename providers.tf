provider "azurerm" {
  features {}
  skip_provider_registration = true

  //required since new version 
  subscription_id = var.subscription_id
}