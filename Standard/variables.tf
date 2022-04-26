variable "resource_group_name" {
  description = "(Required) The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Resource Group."
  type        = map(string)
  default     = {}
}

variable "storage_account_name" {
  description = "(Required) Specifies the name of the storage account. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
  type        = string
}

variable "logic_app_name" {
  description = "(Required) Specifies the name of the Logic App."
  type        = string
}

variable "storage_account_share_name" {
  description = "(Required) Specifies the name of the file share to create on the storage account for logic app files"
  type        = string
}
