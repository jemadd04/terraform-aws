variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
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
