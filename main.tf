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

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Public Subnets ------------------------------
resource "aws_subnet" "Sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "Sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_2"
  }
}

# Private Subnets ------------------------------
resource "aws_subnet" "Sub3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "Sub4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_subnet_2"
  }
}

# Instance running RedHat in subnet sub2 ------------------------------
resource "aws_instance" "main_instance" {
  ami                    = "ami-0b0af3577fe5e3532"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Sub2.id
  vpc_security_group_ids = [aws_security_group.compute_security.id]

  root_block_device {
    volume_size = "20"
  }

  tags = {
    Name = "redhat-instance"
  }
}

resource "aws_security_group" "compute_security" {
  name   = "compute_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Autoscaling Group running RedHat in subnet Sub4 ------------------------------
resource "aws_launch_configuration" "asg_config" {
  name_prefix     = "jmcf-"
  image_id        = "ami-0b0af3577fe5e3532"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.asg_security.id]

  root_block_device {
    volume_size = "20"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo Testing Apache while building this challenge > /var/www/html/index.html'
              EOF
}

resource "aws_autoscaling_group" "coalfire-asg" {
  name                 = "coalfire-autoscaling-group"
  min_size             = 2
  max_size             = 6
  vpc_zone_identifier  = [aws_subnet.Sub4.id]
  launch_configuration = aws_launch_configuration.asg_config.id
  target_group_arns    = [aws_lb_target_group.alb_target_group.arn]
}

resource "aws_security_group" "asg_security" {
  name   = "asg_security"
  vpc_id = aws_vpc.main.id
}

# ALB that listens on port 80 and forwards traffic to the instance in sub4 ------------------------------
# Load Balancer
resource "aws_lb" "application_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.Sub1.id, aws_subnet.Sub2.id]
}

# Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name   = "lb_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "coalfire_lb_sg"
  }

}

# Load Balancer Target Group
resource "aws_lb_target_group" "alb_target_group" {
  name     = "alb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# Load Balancer Listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "coalfire-bucket"
  acl    = "private"

  lifecycle_rule {
    id      = "images"
    enabled = true

    prefix = "images/"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  lifecycle_rule {
    id      = "logs"
    prefix  = "logs/"
    enabled = true

    expiration {
      days = 90
    }
  }
}
