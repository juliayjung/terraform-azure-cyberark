variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "account_tier" {
  type        = string
  description = "The storage account tier: Standard or Premium"
  default     = "Standard"
  # Note about validation
}

variable "account_replication_type" {
  type        = string
  description = "The storage account replication type: LRS, GRS, RAGRS, ZRS, GZRS, RAGRS"
  default     = "GRS"
}