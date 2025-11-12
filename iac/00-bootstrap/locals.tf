locals {
  name_prefix = "${var.project}-${var.aws_region}"
  s3_bucket   = "${var.project}-tfstate-${var.aws_region}"
  ddbl_table  = "${var.project}-tf-locks"
}
