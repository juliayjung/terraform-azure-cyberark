variable "resource_group_name" {
  description = "Name of provided resource group"
  type = string
}

variable "location" {
  description = "the location of resourec group"
  type = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "id of subscription which you can find from resource group"
  type = string
}

# variable "cloud_org" {
#   description = "The organization of terraform cloud"
#   type        = string
#   default     = "Azure-CyberArk"
# }

# variable "cloud_name" {
#   description = "The name of terraform cloud which you can find from app.terraform.io"
#   type        = string
#   default     = "TerraformAzureTest"
# }