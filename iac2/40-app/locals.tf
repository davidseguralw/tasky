locals {
  ecr_repo_name = "${var.project}-${var.environment_name}-tasky2"

  common_tags = merge(
    {
      Project     = var.project
      Component   = "tasky-app"
      Environment = var.environment_name
    },
    var.tags
  )
}
