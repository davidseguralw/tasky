terraform {
  backend "s3" {
    bucket               = "ds5-tfstate-us-west-2"
    key                  = "tasky-iac2/app/terraform.tfstate"
    region               = "us-west-2"
    dynamodb_table       = "ds5-tf-locks"
    encrypt              = true
    workspace_key_prefix = "env"
  }
}
