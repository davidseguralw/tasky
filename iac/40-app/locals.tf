locals {
  # project = "ds5" -> repo name "ds5-tasky"
  ecr_repo_name = "${var.project}-tasky"

  common_tags = merge(
    {
      Project     = var.project
      Component   = "tasky-app"
      Environment = "dev"
    },
    var.tags
  )
}
