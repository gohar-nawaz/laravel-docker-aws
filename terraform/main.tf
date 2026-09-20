terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Aap apni pasandida AWS region set kar sakte hain
}

# 1. Security Group: Web traffic (Port 80) aur SSH access (Port 22) allow karne ke liye
resource "aws_security_group" "laravel_sg" {
  name        = "laravel-docker-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
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

# 2. Key Pair (Agar aap ke pass AWS par SSH key maujood hai to yahan uska naam dein)
resource "aws_key_pair" "deployer" {
  key_name   = "my-ec2-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}
# Automatically fetch the latest Ubuntu 22.04 LTS AMI in ap-south-1
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (Official Ubuntu Owner ID)
}
# 3. EC2 Instance Definition
resource "aws_instance" "web_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"              # Free Tier Eligible

  vpc_security_group_ids = [aws_security_group.laravel_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # Boot script: Docker aur Docker Compose automatically install karega
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y ca-certificates curl gnupg lsb-release git

              # Docker Official Repository Add Karna
              mkdir -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Docker & Compose Install Karna
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

              # Services Start Karna
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Laravel-Docker-Server"
  }
}

# 4. EC2 Instance ka Public IP Output
output "server_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP address of the EC2 Instance"
}