# Variables for AWS region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] 
}

variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# --- Subnet Configuration ---
variable "public_subnet_cidrs" {
  description = "CIDR blocks for Public Web Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# --- Instance Configuration ---

variable "key_name" {
  description = "The name of the key pair"
  type        = string
  default     = "my-key-pair"
}


