variable "resource_group_name" {
  description = "Name of provided resource group provided by the lab"
  type        = string
  nullable    = false
}

variable "location" {
  description = "the location of resourec group"
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "id of subscription which you can find from resource group"
  type        = string
}

