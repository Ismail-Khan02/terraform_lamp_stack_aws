# Creating 1st Web Subnet (Public)
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.main.id  
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  
  map_public_ip_on_launch = true 

  tags = {
    Name        = "public-subnet-1"
    Environment = var.environment
  }
}

