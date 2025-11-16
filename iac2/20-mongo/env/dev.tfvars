project    = "ds5"
aws_region = "us-west-2"

public_subnet_index = 0
instance_type = "t3.small"

ami_id  = "ami-06e5fe51e1101a0d4"
key_name = ""  # set to your EC2 key pair name if you want SSH access

mongo_admin_user = "admin"
mongo_admin_pass = "goodlab"
mongo_db_name    = "tasky"

backup_bucket_name = ""       # leave blank to auto-name
backup_cron        = "30 2 * * *"

tf_state_bucket = "ds5-tfstate-us-west-2"
tf_lock_table   = "ds5-tf-locks"

vpc_id             = "vpc-0e9da4400944de043"
public_subnet_ids = ["subnet-0d9eecdd372024151", "subnet-050923020c8a83645"]
private_subnet_ids = ["subnet-07e6b758e8e44543f", "subnet-04665b9c7b9a9415f"]

