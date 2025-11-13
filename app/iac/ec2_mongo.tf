# Security group for Mongo EC2
resource "aws_security_group" "mongo" {
  name        = "${var.project_name}-mongo-sg"
  description = "SSH from anywhere (lab), Mongo only from VPC private range"
  vpc_id      = aws_vpc.this.id

  # SSH open to Internet (lab requirement)
  ingress { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }

  # Mongo 27017 only from private subnets/VPC CIDR (so EKS nodes can reach)
  ingress { from_port = 27017, to_port = 27017, protocol = "tcp", cidr_blocks = [var.vpc_cidr] }

  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.project_name}-mongo-sg" }
}

# Overly permissive IAM for the EC2 instance (lab requirement: can create VMs)
resource "aws_iam_role" "mongo" {
  name               = "${var.project_name}-mongo-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ec2.amazonaws.com"] }
  }
}
resource "aws_iam_policy" "mongo_over_permissive" {
  name   = "${var.project_name}-mongo-over-permissive"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["ec2:*","s3:*","logs:*","cloudwatch:*","iam:PassRole"],
      Resource = "*"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "mongo_attach" {
  role       = aws_iam_role.mongo.name
  policy_arn = aws_iam_policy.mongo_over_permissive.arn
}
resource "aws_iam_instance_profile" "mongo" {
  name = "${var.project_name}-mongo-profile"
  role = aws_iam_role.mongo.name
}

# Public subnet: pick index 0
resource "aws_instance" "mongo" {
  ami                         = var.mongo_ami_id
  instance_type               = var.mongo_instance_type
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.mongo.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.mongo.name
  user_data                   = templatefile("${path.module}/mongodb-userdata.sh", {
    MONGO_ADMIN_USER = var.mongo_admin_user,
    MONGO_ADMIN_PASS = var.mongo_admin_pass,
    MONGO_DB_NAME    = var.mongo_db_name,
    S3_BUCKET        = var.s3_backup_bucket_name
  })
  tags = { Name = "${var.project_name}-mongo" }
}
