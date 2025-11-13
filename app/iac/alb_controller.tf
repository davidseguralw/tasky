# IRSA for AWS Load Balancer Controller
resource "aws_iam_role" "alb_irsa" {
  name = "${var.project_name}-alb-irsa"
  assume_role_policy = data.aws_iam_policy_document.alb_irsa_trust.json
}
data "aws_iam_policy_document" "alb_irsa_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals { type = "Federated", identifiers = [aws_iam_openid_connect_provider.eks.arn] }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}
resource "aws_iam_policy" "alb_controller" {
  name   = "${var.project_name}-alb-controller"
  policy = file("${path.module}/iam_policies/aws-load-balancer-controller-policy.json")
}
resource "aws_iam_role_policy_attachment" "alb_irsa_attach" {
  role       = aws_iam_role.alb_irsa.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# EKS OIDC provider (for IRSA)
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
data "tls_certificate" "eks" { url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer }

# Helm install
resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_irsa.arn
  }

  depends_on = [aws_eks_node_group.default]
}

# ALB controller IAM policy JSON (save under iac/iam_policies/)
# Download latest from AWS docs for demo; DO NOT edit except name—keeps it verifiable.
