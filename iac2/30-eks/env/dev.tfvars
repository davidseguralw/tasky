project    = "ds5"         
aws_region = "us-west-2"

# paste from: cd iac/10-network && terraform output
vpc_id             = "vpc-0e9da4400944de043"
public_subnet_ids = [
  "subnet-0d9eecdd372024151",
  "subnet-050923020c8a83645",
]
private_subnet_ids = [
  "subnet-07e6b758e8e44543f",
  "subnet-04665b9c7b9a9415f",
]

cluster_version     = "1.29"
node_instance_types = ["t3.medium"]

desired_size = 2
min_size     = 1
max_size     = 3

tags = {
  Environment = "dev"
  Owner       = "ds5"
}
