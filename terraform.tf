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