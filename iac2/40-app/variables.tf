variable "project" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "environment_name" {
  type        = string
  description = "Environment identifier (dev, attack-1, etc.)"
}
