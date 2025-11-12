# 00-bootstrap (WizLab)

One-time bootstrap: remote Terraform state (S3 + DynamoDB) and GitHub OIDC → CI role.

## Usage

# 1) Local state init (first run only)
terraform init

# 2) Apply (creates S3, DynamoDB, OIDC, CI role)
terraform apply -auto-approve \
  -var="project=wizlab" \
  -var="aws_region=us-west-2" \
  -var="github_org=YOUR_GH_ORG" \
  -var="github_repo=YOUR_REPO_NAME"

# 3) Re-init to move state to S3 (after bucket/table exist)
terraform init -migrate-state \
  -backend-config="bucket=<copy output terraform_state_bucket>" \
  -backend-config="dynamodb_table=<copy output terraform_state_lock_table>" \
  -backend-config="region=<your region>"

# 4) Confirm outputs, then paste into your CI secrets:
#    EXEC_ROLE_DEV_ARN, TF_BUCKET, TF_LOCK_TABLE
