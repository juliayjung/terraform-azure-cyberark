variable "resource_group_name" {
  description = "Name of provided resource group provided by the lab"
  type        = string
  nullable    = false
  default     = "rg-dsoa-cyberark-terraform-lab-cc"
}

variable "subscription_id" {
  description = "id of subscription from resource group"
  type        = string
}


variable "location_id" {
  description = "the location of resource group from Settings > Properties"
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "Name of the Virtual Network provided by the lab."
  type        = string
  default     = "vnet-dsoa-cyberark-terraform-lab-cc"
}

variable "subnet_name" {
  description = "Name of the subnet to use in the Virtual Network. Defaults to app."
  type        = string
  default     = "default"
}

variable "common_tags" {
  description = "Map of tags value from Azure portal > resource group > tags"
  type        = map(string)
}

/*
variable "tags_owner" {
  description = "the value from Azure portal > resource group > tags > Owner"
  type        = string
  default     = "Jung, Julia"
}

variable "tags_department" {
  description = "the value from Azure portal > resource group > tags > Department"
  type        = string
  default     = "dsoa"
}

variable "tags_project" {
  description = "the value from Azure portal > resource group > tags > Project"
  type        = string
  default     = "cyberark-terraform"
}
*/

//Create and Configure an Azure load balancer
variable "prefix" {
  description = "Naming prefix for resources. Should be 3-8 characters."
  type        = string
  default     = "terraweb"

  validation {
    condition     = length(var.prefix) >= 3 && length(var.prefix) <= 8
    error_message = "Naming prefix should be between 3-8 characters. Submitted value was ${length(var.prefix)}."
  }
}

variable "application_port" {
  description = "Port to use for the flask application. Defaults to 8080."
  type        = number
  default     = 8080
}

//Create and Configure an Azure VM Scale Set
variable "vm_size" {
  description = "Size of virtual machine to create. Defaults to Standard_A2_v2."
  type        = string
  default     = "Standard_A2_v2"
}

variable "vmss_count" {
  description = "Starting number of VMSS instances to create. Defaults to 2."
  type        = number
  default     = 2

  validation {
    condition     = var.vmss_count >= 1
    error_message = "Count must be 1 or greater. Submitted value was ${var.vmss_count}."
  }
}

variable "admin_username" {
  description = "Admin username for virtual machine. Defaults to azureuser."
  type        = string
  default     = "azureuser"
}