variable "project"    { type = string }
variable "aws_region" { type = string }

# From 10-network (paste outputs)
variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "cluster_version" {
  type    = string
  default = "1.29" # adjust if you want a different supported version
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "environment_name" {
  type        = string
  description = "Environment identifier (dev, attack-1, etc.)"
}

variable "cloud9_role_arn" {
  type = string
}

variable "github_oidc_role_arn" {
  type = string
}
