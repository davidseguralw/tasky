output "terraform_state_bucket" {
  value       = aws_s3_bucket.tf_state.bucket
  description = "S3 bucket for remote Terraform state"
}

output "terraform_state_lock_table" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "DynamoDB table for state locking"
}

output "ci_role_arn" {
  value       = aws_iam_role.github_actions_ci.arn
  description = "Role that GitHub Actions assumes via OIDC"
}
