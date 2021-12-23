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

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_public" {
  type = list
}

variable "subnet_private" {
  type = list
}

variable "ami" {
  type    = string
  default = "ami-0b0af3577fe5e3532"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "coalfire-key"
}

variable "target_type" {
  type    = string
  default = "instance"
}
