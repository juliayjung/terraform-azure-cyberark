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
      name = "TerraformAzure"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true

  //required since new version 
  subscription_id = "28e1e42a-4438-4c30-9a5f-7d7b488fd883"
  //resource_provider_registrations = "none"
}

resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "813-ed60d4cf-hands-on-with-terraform-on-azure"
  location = "eastus"
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "stg${random_string.uniquestring.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
