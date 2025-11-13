resource "aws_s3_bucket" "backup" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_ownership_controls" "backup" {
  bucket = aws_s3_bucket.backup.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket                  = aws_s3_bucket.backup.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Comment DS 11/12 - commented out all the below since there is public block on making buckets public 
# I will inquire about this, but for now I will just use the bucket, we can un-comment this later.
# resource "aws_s3_bucket_policy" "public_read_list" {
#   bucket = aws_s3_bucket.backup.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid: "ListPublic",
#         Effect: "Allow",
#         Principal: "*",
#         Action: [ "s3:ListBucket" ],
#         Resource: "arn:aws:s3:::${local.bucket_name}"
#       },
#       {
#         Sid: "ReadPublic",
#         Effect: "Allow",
#         Principal: "*",
#         Action: [ "s3:GetObject" ],
#         Resource: "arn:aws:s3:::${local.bucket_name}/*"
#       }
#     ]
#   })
# }
