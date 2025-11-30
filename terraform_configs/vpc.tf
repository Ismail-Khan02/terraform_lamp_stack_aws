# VPC Configuration

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr 
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
    Environment = var.environment
  }
}

# 1. Create an Internet Gateway (The "Door" to the VPC) 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 2. Create a Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# 3. Associate the Route Table with the Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}