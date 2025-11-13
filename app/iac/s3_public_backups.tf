resource "aws_s3_bucket" "backups" {
  bucket = var.s3_backup_bucket_name
  tags   = { Name = "${var.project_name}-mongo-backups" }
}

# Turn off block public access to allow public list/read (lab only)
resource "aws_s3_bucket_public_access_block" "backups" {
  bucket                  = aws_s3_bucket.backups.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy: public list/read (INTENTIONALLY INSECURE FOR LAB)
data "aws_iam_policy_document" "public_read_list" {
  statement {
    sid     = "AllowList"
    effect  = "Allow"
    principals { type = "*", identifiers = ["*"] }
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.backups.arn]
  }
  statement {
    sid     = "AllowRead"
    effect  = "Allow"
    principals { type = "*", identifiers = ["*"] }
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.backups.arn}/*"]
  }
}
resource "aws_s3_bucket_policy" "backups" {
  bucket = aws_s3_bucket.backups.id
  policy = data.aws_iam_policy_document.public_read_list.json
}
