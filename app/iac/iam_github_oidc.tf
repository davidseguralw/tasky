resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub
}

data "aws_iam_policy_document" "gh_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals { type = "Federated", identifiers = [aws_iam_openid_connect_provider.github.arn] }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*",
        "repo:${var.github_owner}/${var.github_repo}:pull_request"
      ]
    }
  }
}

# IaC role (Terraform apply)
resource "aws_iam_role" "gh_iac" {
  name               = "${var.project_name}-gh-oidc-iac"
  assume_role_policy = data.aws_iam_policy_document.gh_trust.json
}
resource "aws_iam_role_policy" "gh_iac_inline" {
  name = "${var.project_name}-gh-iac-inline"
  role = aws_iam_role.gh_iac.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["eks:*","ec2:*","iam:*","ecr:*","s3:*","cloudwatch:*","logs:*","autoscaling:*","elasticloadbalancing:*","dynamodb:*","sts:*"],
      Resource = "*"
    }]
  })
}

# App role (build/push/deploy)
resource "aws_iam_role" "gh_app" {
  name               = "${var.project_name}-gh-oidc-app"
  assume_role_policy = data.aws_iam_policy_document.gh_trust.json
}
resource "aws_iam_role_policy" "gh_app_inline" {
  name = "${var.project_name}-gh-app-inline"
  role = aws_iam_role.gh_app.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect="Allow", Action=["ecr:GetAuthorizationToken"], Resource="*" },
      { Effect="Allow", Action=["ecr:BatchCheckLayerAvailability","ecr:CompleteLayerUpload","ecr:UploadLayerPart","ecr:InitiateLayerUpload","ecr:PutImage","ecr:BatchGetImage","ecr:GetDownloadUrlForLayer"], Resource="*" },
      { Effect="Allow", Action=["eks:DescribeCluster"], Resource="*" },
      { Effect="Allow", Action=["sts:AssumeRole","sts:GetCallerIdentity"], Resource="*" }
    ]
  })
}
