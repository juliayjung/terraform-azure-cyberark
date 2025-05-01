terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      "source" = "hashicorp/azurerm"
      version  = "3.106.1"//"3.43.0"
    }

    //Deploy Flux CD Using Helm
    helm = {
      source = "hashicorp/helm"
      version = "~>2.0"
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