variable "aws_access_key" {
  type    = string
  default = "AKIAXLGTAZKJXJ7XPIVR"
}

variable "aws_secret_access_key" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "ec2_ami" {
  type    = string
  default = "ami-0440e5026412ff23f"
}

variable "ec2_type" {
  type    = string
  default = "c5a.xlarge"
}

variable "az1" {
  type    = string
  default = "eu-north-1a"
}

variable "az2" {
  type    = string
  default = "eu-north-1b"
}

variable "hosted_zone_id" {
  type    = string
  default = "Z06601991ZHJ55QUAMGVM"
}

variable "hosted_zone_name" {
  type    = string
  default = "xelerate.solutions"
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
}

resource "aws_security_group" "ec2_sg" {
  name        = "Rensair Prod Security Group"
  description = "Rensair Prod Security Group Created on Sep 09 2022"

  ingress {
    description = "SSH from the internet"
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

  tags = {
    "Name"        = "Rensair_Prod_SecurityGroup",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_eip" "ec2_eip" {
  vpc = true
  tags = {
    "Name"        = "Rensair_Prod_Elastic_IP",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "rensair-prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZr/spjvxH4NboR+7TUQhuW+E9ZOCM+iG+3fKrEe514LmOP5+uvY3l6gR86kMz5PjEgxTwFqT7ZUJJjrhi3HP11E/pU2IKVYXW9u+MoViWOMqDu3mvqvDqv79NAubFlpq3gfqCaO9kLuCRbNFcgZpUPs43dBBKXb4tRTOqrIuT5YA2loBZoUOgVSHqngoLa6x3pDDRvjcY0a9Iq09fgvYboE2HFuuE3KS1nvTzKlWBqj66aSxzPIYFwvo2txZpCll9lCrQGeTOyjpOVwvFQ67jAxy3Xy7SmR3p4b22eHl6RZ5ByF1mIzw3XJ9fI1wTupRH2km3RBhEnHTzFJrnzj/sP5wVUJlZ7AXshXHicW8/7XeuK03+YG0lIzueAlywF/vZTmNTDIackmjx+a199CSpGhRoZqWIDMkHNGoknwi2zKnkTTuOZ5s087ZNi/BNLbzIGMrvY1dTZN65jPMbuDSAbwH+lXfh5/Io+tFzD4i5ro/jl350hblB3Wqf2j4SQFU= navaid@navaid-Inspiron-3501"
  tags = {
    "Name"        = "Rensair_Prod_Keypair",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_ebs_volume" "ec2_ebs" {
  availability_zone = var.az1
  size              = 250
  tags = {
    "Name"        = "Rensair_Prod_Volume",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_instance" "ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_type
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_keypair.id
  availability_zone           = var.az1

  tags = {
    "Name"        = "Rensair_Prod_Keypair",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_volume_attachment" "ec2_ebs_volume_attachment" {
  device_name = "dev/sda1"
  volume_id   = aws_ebs_volume.ec2_ebs.id
  instance_id = aws_instance.ec2.id
}

resource "aws_eip_association" "ec2_eip_association" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2_eip.id
}


variable "health_check" {
  type = map(string)
  default = {
    "timeout"             = "10"
    "interval"            = "20"
    "path"                = "/"
    "port"                = "80"
    "unhealthy_threshold" = "2"
    "healthy_threshold"   = "3"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "Rensair Prod ALB Security Group"
  description = "Rensair Prod ALB Security Group Created on Sep 09 2022"

  ingress {
    description = "Http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "Rensair_Prod_ALB_SecurityGroup",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = var.az1
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = var.az2
}

resource "aws_alb" "alb" {
  name               = "Rensair-Prod-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  tags = {
    "Name"        = "Rensair_Prod_ALB",
    "Environment" = "Rensair_Prod"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "Rensair-Target-Group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    timeout             = var.health_check["timeout"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
  }

  tags = {
    "Name"        = "Rensair_Prod_TargetGroup",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_lb_target_group_attachment" "alb_targetgroup_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = "xelerate.solutions"
  subject_alternative_names = ["*.xelerate.solutions"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name"        = "Rensair_Prod_ACM",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }

  tags = {
    "Name"        = "Rensair_Prod_HTTPS_Listener",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }

  tags = {
    "Name"        = "Rensair_Prod_HTTP_Listener",
    "Environment" = "Rensair_Prod"
  }
}

resource "aws_route53_record" "rensair_backend" {
  zone_id = var.hosted_zone_id
  name    = "rensair-backend.${var.hosted_zone_name}"
  type    = "A"
  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = var.hosted_zone_id
    evaluate_target_health = true
  }
}