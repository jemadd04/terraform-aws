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

# Instance running RedHat in subnet sub2 ------------------------------
resource "aws_instance" "main_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_public, 1)
  vpc_security_group_ids = [aws_security_group.compute_security.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = "20"
  }

  tags = {
    Name = "redhat-instance"
  }
}

resource "aws_security_group" "compute_security" {
  name   = "jmcf_redhat_sg"
  vpc_id = var.vpc_id

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
  image_id        = var.ami
  instance_type   = var.instance_type
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
  vpc_zone_identifier  = [element(var.subnet_private, 1)]
  launch_configuration = aws_launch_configuration.asg_config.id
  target_group_arns    = [aws_lb_target_group.alb_target_group.arn]
}

resource "aws_security_group" "asg_security" {
  name   = "asg_security"
  vpc_id = var.vpc_id
}

# ALB that listens on port 80 and forwards traffic to the instance in sub4 ------------------------------
# Load Balancer
resource "aws_lb" "application_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [element(var.subnet_public, 0), element(var.subnet_public, 1)]
}

# Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name   = "lb_security_group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
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
  name        = "alb-target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type
  health_check {
    interval = 10
    path     = "/"
    port     = 80
  }
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
