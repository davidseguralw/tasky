variable "project"    { type = string }
variable "aws_region" { type = string }

# Public subnet index to place the VM (0 or 1)
variable "public_subnet_index" {
  type    = number
  default = 0
}

variable "instance_type" { 
  type = string
  default = "t3.small"
  }

# Use the specific AMI you provided
variable "ami_id" {
  type    = string
  default = "ami-06e5fe51e1101a0d4"
}

# Optional: SSH key pair name (must exist in account); leave "" to skip
variable "key_name" {
  type    = string
  default = ""
}

# Mongo creds (UPPERCASE placeholders in userdata)
variable "mongo_admin_user" { type = string }
variable "mongo_admin_pass" { type = string }
variable "mongo_db_name"    { 
  type = string
  default = "tasky" 
}

# S3 backup bucket name; if empty, one will be generated
variable "backup_bucket_name" { 
  type = string
  default = "" 
}

# Cron schedule (crontab expression) for daily backup
variable "backup_cron" {
  type = string
  default = "30 2 * * *" 
} # 02:30 daily

# Backend glue for remote_state
variable "tf_state_bucket" { type = string }
variable "tf_lock_table"   { type = string }
