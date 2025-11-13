# 20-mongo/remote_state.tf (no remote state)
variable "vpc_id"             { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

data "aws_vpc" "this" { id = var.vpc_id }

data "aws_subnet" "target_public" {
  id = var.public_subnet_ids[var.public_subnet_index]
}

data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}
