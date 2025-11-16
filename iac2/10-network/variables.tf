variable "project"    { type = string }
variable "aws_region" { type = string }

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Two AZs to spread subnets across"
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Two CIDRs for public subnets (one per AZ)"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Two CIDRs for private subnets (one per AZ)"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "environment_name" {
  type        = string
  description = "Short environment ID (dev, attack-1, blue-team, etc.)"
}
