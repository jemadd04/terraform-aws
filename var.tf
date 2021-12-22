variable "prefix" {
  default = "jmcf"
}

variable "rg-name" {
  default = "coalfireresourcegroup"
}

variable "location" {
  default = "eastus"
}


variable "ami" {
  default = "ami-04505e74c0741db8d"
}

variable "public_subnet" {
  type    = list
  default = ["value"]
}
