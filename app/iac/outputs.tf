output "eks_name"     { value = aws_eks_cluster.this.name }
output "ecr_url"      { value = aws_ecr_repository.app.repository_url }
output "mongo_public_ip" { value = aws_instance.mongo.public_ip }
output "mongo_host_for_uri" { value = aws_instance.mongo.public_dns }
output "mongo_uri_example" {
  value = "mongodb://${var.mongo_admin_user}:${var.mongo_admin_pass}@${aws_instance.mongo.public_dns}:27017/${var.mongo_db_name}?authSource=admin"
}
output "s3_backup_bucket" { value = aws_s3_bucket.backups.bucket }
