output "instance_id"        { value = aws_instance.mongodb.id }
output "private_ip"         { value = aws_instance.mongodb.private_ip }
output "public_ip"          { value = aws_instance.mongodb.public_ip }
output "security_group_id"  { value = aws_security_group.mongo.id }
output "backup_bucket_name" { value = aws_s3_bucket.backup.bucket }

output "mongo_uri" {
  value     = "mongodb://${var.mongo_admin_user}:${var.mongo_admin_pass}@${aws_instance.mongodb.private_ip}:27017/${var.mongo_db_name}?authSource=admin"
  sensitive = true
}
