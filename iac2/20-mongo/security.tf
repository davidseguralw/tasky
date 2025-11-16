# SG: SSH open to world (22), Mongo 27017 only from private subnets (K8s nodes)
resource "aws_security_group" "mongo" {
  name        = "${local.name_prefix}-mongo-sg"
  description = "SSH public; Mongo from private subnets only"
  vpc_id      = data.aws_vpc.this.id
  tags        = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "ssh_world" {
  security_group_id = aws_security_group.mongo.id
  cidr_ipv4         = "0.0.0.0/0"      # INSECURE; demo-only
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "mongo_from_private_subnets" {
  for_each          = data.aws_subnet.private
  security_group_id = aws_security_group.mongo.id
  cidr_ipv4         = each.value.cidr_block
  from_port         = 27017
  to_port           = 27017
  ip_protocol       = "tcp"
  description       = "MongoDB from private/K8s subnets only"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.mongo.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all egress"
}
