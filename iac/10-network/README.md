# 10-network

Creates a demo-ready VPC:
- 2x public subnets (for ingress/NAT/Cloud9)
- 2x private subnets (for EKS nodes, Mongo VM)
- IGW, 1x NAT Gateway (cost-saving), route tables

## Apply (example)
terraform init \
  -backend-config="bucket=${TF_BUCKET}" \
  -backend-config="dynamodb_table=${TF_LOCK_TABLE}" \
  -backend-config="region=${AWS_REGION}"

terraform apply -auto-approve -var-file=env/dev.tfvars
