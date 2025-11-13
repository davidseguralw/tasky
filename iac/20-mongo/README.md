# 20-data-mongo (public VM + daily S3 backup)

Creates:
- MongoDB 6.0 VM in a **public subnet**
- Public **SSH (22/tcp)** from anywhere
- MongoDB (27017/tcp) **only from Kubernetes/private subnets**
- Overly-permissive **instance role** (Admin) for demo
- Daily **mongodump → S3**; bucket allows **public read/list**

## Apply
terraform init \
  -backend-config="bucket=${TF_BUCKET}" \
  -backend-config="dynamodb_table=${TF_LOCK_TABLE}" \
  -backend-config="region=${AWS_REGION}"

terraform apply -auto-approve -var-file=env/dev.tfvars

## Outputs
- private_ip
- public_ip
- security_group_id
- mongo_uri
- backup_bucket_name
