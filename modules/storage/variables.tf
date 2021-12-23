variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region"
}

variable "access_key" {
  default = "AKIATF6QK54SGEJRJVMO"
}

variable "secret_key" {
  default = "dzR/Ol87Maizzl+ogMhTWHdMVVetSxUD7eDawk0p"
}

variable "bucket_name" {
  type        = string
  default     = "jmcf-bucket"
  description = "Bucket Name"
}

variable "bucket_acl" {
  type    = string
  default = "private"
}
