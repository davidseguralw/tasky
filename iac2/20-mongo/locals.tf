locals {
  name_prefix = "${var.project}-${var.environment_name}-${var.aws_region}"

  common_tags = {
    Project     = var.project
    Component   = "mongo"
    Environment = var.environment_name
  }
}
