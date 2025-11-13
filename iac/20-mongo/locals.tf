locals {
  name_prefix = "${var.project}-${var.aws_region}"
  tags = {
    Project     = var.project
    Component   = "mongo"
    Environment = "dev"
  }
  bucket_name = var.backup_bucket_name != "" ? var.backup_bucket_name : "${var.project}-mongo-backups-${var.aws_region}"
}
