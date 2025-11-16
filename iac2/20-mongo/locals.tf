locals {
  name_prefix = "${var.project}-${var.environment_name}-${var.aws_region}"

  tags = {
    Project     = var.project
    Component   = "mongo"
    Environment = var.environment_name
  }

  # NOTE: now includes environment_name in default bucket name
  bucket_name = var.backup_bucket_name != "" ?
    var.backup_bucket_name :
    "${var.project}-${var.environment_name}-mongo-backups-${var.aws_region}"
}
