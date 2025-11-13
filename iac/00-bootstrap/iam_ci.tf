# 1) GitHub OIDC Provider (global per account)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Current GH Actions root CA thumbprint (AWS keeps this consistent; update if GH changes CA)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2) Trust policy for CI role
data "aws_iam_policy_document" "ci_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Limit to this repo
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }

    # Optional branch pin
    dynamic "condition" {
      for_each = var.github_ref_condition == "" ? [] : [1]
      content {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:ref"
        values   = [var.github_ref_condition]
      }
    }
  }
}

# 3) CI Role with broad permissions (speed-to-demo)
resource "aws_iam_role" "github_actions_ci" {
  name               = "${local.name_prefix}-github-ci"
  assume_role_policy = data.aws_iam_policy_document.ci_assume_role.json
  tags = { Project = var.project }
}

# For maximum speed (avoid IAM friction), attach AdministratorAccess.
# Tighten later as needed.
resource "aws_iam_role_policy_attachment" "ci_admin_attach" {
  role       = aws_iam_role.github_actions_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 4) (Optional) Per-env exec role alias (same role now; you can split later)
# We just output this role’s ARN as the "exec role".
