data "template_file" "userdata" {
  template = file("${path.module}/files/mongodb-userdata.sh")
  vars = {
    MONGO_ADMIN_USER = var.mongo_admin_user
    MONGO_ADMIN_PASS = var.mongo_admin_pass
    MONGO_DB_NAME    = var.mongo_db_name
    BACKUP_BUCKET    = local.bucket_name
    BACKUP_CRON      = var.backup_cron
  }
}

resource "aws_instance" "mongodb" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.target_public.id
  vpc_security_group_ids      = [aws_security_group.mongo.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.mongo.name
  key_name                    = var.key_name != "" ? var.key_name : null

  user_data = data.template_file.userdata.rendered

  tags = merge(local.tags, { Name = "${local.name_prefix}-mongodb-public" })
}
