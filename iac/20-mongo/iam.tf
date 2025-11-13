resource "aws_iam_role" "mongo_ec2" {
  name = "${local.name_prefix}-mongo-admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = local.tags
}

# Admin access (lets the VM create VMs, etc.) — INSECURE; demo-only
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.mongo_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# SSM core for Session Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.mongo_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "mongo" {
  name = "${local.name_prefix}-mongo-admin"
  role = aws_iam_role.mongo_ec2.name
  tags = local.tags
}
