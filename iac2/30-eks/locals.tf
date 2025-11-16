locals {
  name_prefix = "${var.project}-${var.environment_name}-${var.aws_region}"

  common_tags = merge(
    {
      Project     = var.project
      Component   = "eks"
      Environment = var.environment_name
    },
    var.tags
  )
}
