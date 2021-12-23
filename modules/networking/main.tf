terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.1"
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id
}


# Public Subnets ------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "Sub${count.index + 1}"
  }
}

# Private Subnets ------------------------------
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnets)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.private_subnets, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "Sub${count.index + 3}"
  }
}

#-------------Route Table for Public Subnets-----------------------

resource "aws_route_table" "public_route" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

#-------------Route Table for Private Subnets-----------------------

resource "aws_route_table" "private_route" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_route_table" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_route_table" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route.id
}

resource "aws_network_interface" "testing-nwi" {
  subnet_id       = element(aws_subnet.public_subnets.*.id, 1)
  security_groups = [var.security_group_id]
}

resource "aws_eip" "coalfire-eip" {
  vpc               = true
  network_interface = aws_network_interface.testing-nwi.id
  depends_on = [
    aws_internet_gateway.gw
  ]
}
