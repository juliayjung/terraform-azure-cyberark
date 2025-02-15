terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      "source" = "hashicorp/azurerm"
      version  = "3.43.0"
    }
  }

  //value from https://app.terraform.io/app/Azure-CyberArk/workspaces/TerraformAzure
  cloud {
    organization = "Azure-CyberArk"
    workspaces {
      name = "TerraformAzureTest"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true

  //required since new version 
  subscription_id = "9734ed68-621d-47ed-babd-269110dbacb1"
  //resource_provider_registrations = "none"
}

resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "1-e257913a-playground-sandbox"
  location = "eastus"
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "stg${random_string.uniquestring.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
