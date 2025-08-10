variable "prefix" {
  default = "dev"
  type    = string
}

variable "location" {
  default = "eastus2"
  type    = string
}

variable "default_vnet_address_space" {
  default = ["10.0.0.0/16"]
  type    = list(string)
}

variable "default_subnet_address_space" {
  default = ["10.0.1.0/24"]
  type    = list(string)
}
