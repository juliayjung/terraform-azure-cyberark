variable "resource_group_name" {
  description = "Name of provided resource group provided by the lab"
  type        = string
  nullable    = false
}

variable "subscription_id" {
  description = "id of subscription which you can find from resource group"
  type        = string
}


variable "location_id" {
  description = "the location of resource group from Settings > Properties"
  type        = string
  default     = "eastus"
}
