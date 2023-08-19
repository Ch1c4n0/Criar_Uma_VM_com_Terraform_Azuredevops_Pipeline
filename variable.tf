variable "resource_group_location" {
  default     = "westus"
  description = "Location1 of the resource group."
}

variable "prefix" {
  type        = string
  default     = "vm-"
  description = "Prefix - nome dos recursos"
}