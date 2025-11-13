locals {
  name_prefix = "${var.project}-${var.aws_region}"

  common_tags = merge(
    {
      Project     = var.project
      Component   = "eks"
      Environment = "dev"
    },
    var.tags
  )
}
