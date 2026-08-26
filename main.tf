provider "aws" {
  region = "ap-south-1"
}

# -------------------------
# Variables
# -------------------------

variable "ami_id" {
  default = "ami-0ac7b260cf76d8865"
}

variable "subnet_id" {
  default = "subnet-0b250c1592d3a549d"
}

variable "key_name" {
  default = "Passkey"
}

# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "application_servers" {
  name        = "application-servers-sg"
  description = "Security group for application servers"
  vpc_id      = "vpc-043b59f78d33d48e2"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["15.252.140.148/32"]
  }

  ingress {
    description = "Application port"
    from_port   = 8080
    to_port     = 8080
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
    Name = "application-servers-sg"
  }
}

resource "aws_security_group" "web_servers" {
  name        = "web-servers-sg"
  description = "Security group for web servers"
  vpc_id      = "vpc-043b59f78d33d48e2"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["15.252.140.148/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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
    Name = "web-servers-sg"
  }
}

# -------------------------
# Application Servers
# -------------------------

resource "aws_instance" "application_servers" {
  count = 2

  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.application_servers.id
  ]

  tags = {
    Name = "application-server-${count.index + 1}"
    Role = "Application"
  }
}

# -------------------------
# Web Servers
# -------------------------

resource "aws_instance" "web_servers" {
  count = 2

  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.web_servers.id
  ]

  tags = {
    Name = "web-server-${count.index + 1}"
    Role = "Web"
  }
}
