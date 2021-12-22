variable "prefix" {
  default = "jmcf"
}

variable "rg-name" {
  default = "coalfireresourcegroup"
}

variable "location" {
  default = "eastus"
}

variable "access_key" {
  default = "AKIATF6QK54SN6KUF2P6"
}

variable "secret_key" {
  default = "+p+KjSeQujs3qhzA1VRw9QicfFgVKg4RVVmKB+Ow"
}

variable "ami" {
  default = "ami-04505e74c0741db8d"
}

variable "public_subnet" {
  type    = list
  default = ["value"]
}
