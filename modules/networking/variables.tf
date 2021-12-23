variable "region" {
  type    = string
  default = "us-east-1"
}

variable "access_key" {
  default = "AKIATF6QK54SGEJRJVMO"
}

variable "secret_key" {
  default = "dzR/Ol87Maizzl+ogMhTWHdMVVetSxUD7eDawk0p"
}

variable "vpc_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "public_subnets" {
  type    = list
  default = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "private_subnets" {
  type    = list
  default = ["10.1.2.0/24", "10.1.3.0/24"]
}

variable "availability_zones" {
  type    = list
  default = ["us-east-1a", "us-east-1b"]
}
