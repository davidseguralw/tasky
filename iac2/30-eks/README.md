# 30-eks

Minimal EKS cluster + managed node group:
- Creates IAM roles for cluster + nodes
- Creates security groups
- Uses existing VPC + private subnets from 10-network
- No remote_state; VPC/subnets are passed as vars

## Apply (example)

terraform init \
  -backend-config="bucket=${TF_BUCKET}" \
  -backend-config="dynamodb_table=${TF_LOCK_TABLE}" \
  -backend-config="region=${AWS_REGION}"

terraform apply -auto-approve -var-file=env/dev.tfvars

## Outputs

- cluster_name
- cluster_endpoint
- cluster_ca
- node_group_name
