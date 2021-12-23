provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# VPC ------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Networking Module
module "networking_subnet_resources" {
  source            = "./modules/networking"
  vpc_id            = aws_vpc.main.id
  security_group_id = module.compute.security_group_id
}

# RedHat Compute Module
module "redhat_instance_resources" {
  source         = "./modules/compute"
  vpc_id         = aws_vpc.main.id
  vpc_cidr_block = aws_vpc.main.cidr_block
  subnet_public  = module.networking.public_subnets
  subnet_private = module.networking.private_subnets
}

# Storage Module
module "s3_storage" {
  source = "./modules/storage"
}
