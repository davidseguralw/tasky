output "tasky_ecr_repo_name" {
  description = "ECR repository name for Tasky"
  value       = aws_ecr_repository.tasky.name
}

output "tasky_ecr_repo_url" {
  description = "Full ECR repository URL"
  value       = aws_ecr_repository.tasky.repository_url
}
