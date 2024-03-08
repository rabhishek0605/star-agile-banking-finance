# Initialize Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Creating a VPC
resource "aws_vpc" "proj-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "proj-ig" {
  vpc_id = aws_vpc.proj-vpc.id

  tags = {
    Name = "gateway1"
  }
}

# Setting up the route table
resource "aws_route_table" "proj-rt" {
  vpc_id = aws_vpc.proj-vpc.id

  route {
    # pointing to the internet
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proj-ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.proj-ig.id
  }

  tags = {
    Name = "rtl"
  }
}

# Creating a subnet
resource "aws_subnet" "proj-subnet" {
  vpc_id            = aws_vpc.proj-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
}

# Associating the subnet with the route table
resource "aws_route_table_association" "proj-rt-sub-assoc" {
  subnet_id      = aws_subnet.proj-subnet.id
  route_table_id = aws_route_table.proj-rt.id
}

# Creating a Security Group
resource "aws_security_group" "proj-sg" {
  name        = "proj-sg"
  description = "Enable web traffic for the project"
  vpc_id      = aws_vpc.proj-vpc.id

  ingress {
    description = "HTTP traffic"
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 80 inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a new network interface
resource "aws_network_interface" "proj-ni" {
  subnet_id        = aws_subnet.proj-subnet.id
  private_ips      = ["10.0.1.10"]
  security_groups = [aws_security_group.proj-sg.id]
}

# Attaching an elastic IP to the network interface
resource "aws_eip" "proj-eip" {
  vpc                  = true
  network_interface    = aws_network_interface.proj-ni.id
  associate_with_private_ip = "10.0.1.10"
}

# Creating an Ubuntu EC2 instance
resource "aws_instance" "Prod-Server" {
  ami              = "ami-0ef82eeba2c7a0eeb"
  instance_type    = "t2.micro"
  availability_zone = "ap-south-1b"
  key_name         = "demo"
  public_key       = "PuTTY-User-Key-File-2: ssh-rsa
Encryption: none
Comment: New-KP
Public-Lines: 6
AAAAB3NzaC1yc2EAAAADAQABAAABAQCMKYyFIRrsgysU4nIwLOdCrnGMFBf+eVvO
LWeNHqsGIasFfeEmBX6DBxYIfrTGZfhExiN3Ih0bIGeiRONVgumjylztuwbWqFQq
ZkUW0FkQxXXbJu7LUMo3yrap6V04ISRRBjmAwSy16R54ssvXV6Eoa+gYk01FkrSR
alsC+72OgGcWMerOpxaTcs6umF9vqK/LbEYjkYw6RbMsf+CvAOp73IWckFU3EPS2
4yaDhrZp2Ezl4OiDxL6cZwHIJzGD77Q9ASxQ7Vav13ehPTTP9dQYyBVAjUrS9MR3
cQpbofhl2yiVKy7vY7iIO/0Zy17Tl+uMILsIotMlFPLhRTy2MAw3
Private-Lines: 14
AAABAF0MHCgpEQmgDlKf/bQzqxbeXazjjgY2pJacF9lcWacJZNKRfY1TKmhrpNng
27u15/ooG1U0RWRDv+i+mLik3twINGbxuRl5x94Z5JW/nNEAdTwWfYJl0Mj2/wqP
TH49qjFL05LBKyBccQkpkR8VInyGHh9qcmrUeKDsnRy+6FkXslBi834pJMDOWvUa
Qn+wie1T2U5Qxc45f07cT5zhXALdMLdi8tkRHP0e24X3OoKOaELoRP3n5JSquT/8
refxlHd7FF0QsyyCy44hbFgpFRuOWslGubpbyPmghD/cHH0AVxQnIiMItSi0HEg6
fE14Oamss7cHoRIVEvmi1aY1wyEAAACBAM9Q2nR4ZQzz9m/g8es3rJNnBGcGgjw9
z7LG1ezCRCcBltjvPOUIU6b/olXJ7/a0YOn2hvwc8cmJnKNAn9pA3kCxfGAhaN87
awj1cvYUlCxZW62V/T19Ec9CCaSX1ldxAfsJ0SxeeeYE4cPAEuKvDbBHkMMyUHsx
iMHk3qPAiWnHAAAAgQCtE6VVUg8QZVmkyUbsAfluFQTGBE4N00O2epQIH7AjDUqX
GLyIbk/Gwyterh9H7WIv5PNvQeJgb/428t32JB1pTOcXs5F7GggztPIhcXx9ub4Z
EYgYxJBLv+s50fBO6GGEplo/46gZ/yoQCsHa7h1eagk/xaNfgJtHIqwRy5/KEQAA
AIBPJhA5nESMOlVE4tH5H6cd1spDMPQbpsHmR1mrLKVgFGDBrnTP9ka/PPPECE9O
kuM9jqVElAAb9ygmytqfN4oKRx6LToVEYNOn2uEPKJYaqZ2LZOTDtIKnR2trwI/h
bMGO4nzOMrhULP/aQD4r7Jp5dnUhMKMHvSyumj2MAR0JXQ==
Private-MAC: 2c6b08dc809898494339947c77adf27b84c23b69"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.proj-ni.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt install docker.io -y
    sudo systemctl enable docker
    sudo docker run -itd -p 8083:8081 rabhishek0605/banking-project
    sudo docker start $(docker ps -aq)
  EOF

  tags = {
    Name = "Prod-Server"
  }
}
