variable "project_name" { description = "Prefix for names"; type = string; default = "wizlab" }
variable "region"       { description = "AWS region"; type = string; default = "us-west-2" }

variable "vpc_cidr"     { description = "CIDR for VPC"; type = string; default = "10.0.0.0/16" }
variable "public_subnet_cidrs"  { type = list(string); default = ["10.0.0.0/20","10.0.16.0/20"] }
variable "private_subnet_cidrs" { type = list(string); default = ["10.0.128.0/20","10.0.144.0/20"] }

# ======= GitHub OIDC trust (MUST set to your repo) =======
variable "github_owner" { type = string, description = "GitHub org/user", default = "davidseguralw" }
variable "github_repo"  { type = string, description = "GitHub repo name", default = "tasky" }

# ======= Mongo EC2 settings =======
variable "mongo_instance_type" { type = string, default = "t3.small" }
# MUST choose an AMI >= 1 year old to satisfy exercise. Verify it exists in your region.
variable "mongo_ami_id"        { type = string, default = "ami-0923359e80cfe4623" }
variable "mongo_admin_user"    { type = string, default = "admin" }
variable "mongo_admin_pass"    { type = string, default = "pa55w0rd" } # ok for lab only
variable "mongo_db_name"       { type = string, default = "taskydb" }

# ======= S3 for backups =======
variable "s3_backup_bucket_name" {
  type        = string
  default     = "ds-lab4w-2025-11-10-ds" # must be globally unique if you keep it
  description = "Bucket with public list/read (lab only)"
}

# EKS instance type and size (private nodes)
variable "eks_instance_types" { type = list(string), default = ["t3.medium"] }
variable "eks_desired_size"   { type = number, default = 2 }
