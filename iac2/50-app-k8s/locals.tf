locals {
  name_prefix = "${var.project}-${var.environment_name}"

  image = "${var.image_repo}:${var.image_tag}"

  common_labels = {
    app         = "tasky"
    project     = var.project
    environment = var.environment_name
  }

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment_name
      Component   = "tasky-k8s"
    },
    var.tags
  )
}
