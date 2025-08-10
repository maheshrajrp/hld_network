module "devone" {
  source   = "../modules"
  prefix   = var.prefix
  location = var.location
}

variable "prefix" {
  description = "Prefix for resources"
  type        = string
  default     = "devone"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}
