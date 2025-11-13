resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [for s in aws_subnet.private : s.id]
  }

  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
  tags = { Name = "${var.project_name}-eks" }
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}
data "aws_iam_policy_document" "eks_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["eks.amazonaws.com"] }
  }
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node group (private)
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-eks-nodes-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_trust.json
}
data "aws_iam_policy_document" "eks_nodes_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ec2.amazonaws.com"] }
  }
}
resource "aws_iam_role_policy_attachment" "nodes_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-ng"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]

  scaling_config { desired_size = var.eks_desired_size, max_size = 3, min_size = 1 }
  instance_types = var.eks_instance_types

  depends_on = [aws_eks_cluster.this]
}

# For kubernetes/helm providers
data "aws_eks_cluster" "this"       { name = aws_eks_cluster.this.name }
data "aws_eks_cluster_auth" "this"  { name = aws_eks_cluster.this.name }
