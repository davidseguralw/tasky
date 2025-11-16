variable "project" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "environment_name" {
  type        = string
  description = "Environment identifier (dev, attack-1, etc.)"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster to deploy into"
}

variable "image_repo" {
  type        = string
  description = "ECR repo URI (without tag), e.g. 123.dkr.ecr.us-west-2.amazonaws.com/ds5-dev-tasky"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag (Git SHA, etc.)"
}

variable "app_namespace" {
  type        = string
  default     = "tasky"
}

variable "app_port" {
  type        = number
  default     = 8080
}

variable "replicas" {
  type        = number
  default     = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
