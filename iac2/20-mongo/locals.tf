locals {
  # Include env in names
  name_prefix = "${var.project}-${var.environment_name}-${var.aws_region}"

  tags = {
    Project     = var.project
    Component   = "mongo"
    Environment = var.environment_name
  }

  # Use explicit backup bucket if set, otherwise default convention
  bucket_name = var.backup_bucket_name != "" ?
    var.backup_bucket_name :
    "${var.project}-mongo-backups-${var.aws_region}"
}
