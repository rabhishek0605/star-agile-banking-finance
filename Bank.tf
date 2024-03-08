provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}

# Security Group Setup
resource "aws_security_group" "example" {
  vpc_id = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "example" {
  subnet_id   = aws_subnet.example.id
  private_ips = ["10.0.1.10"]  # Update with desired IP address

  tags = {
    Name = "Example Network Interface"
  }
}

resource "aws_eip" "proj-eip" {
  vpc                  = true
  network_interface    = aws_network_interface.example.id
  associate_with_private_ip = "10.0.1.10"
}

resource "aws_instance" "test-Server" {
  ami              = "ami-07d9b9ddc6cd8dd30"
  instance_type    = "t2.micro"
  availability_zone = "us-east-1a"
  key_name         = "New-KP"
  
  tags = {
    Name = "test-Server"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.example.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOF
}
