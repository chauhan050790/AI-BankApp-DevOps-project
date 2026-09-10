project_name = "ai-bankapp"

environment = "dev"

owner = "Vipin Kumar"

aws_region = "ap-south-1"

vpc_cidr = "10.0.0.0/16"

azs = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

intra_subnets = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]

single_nat_gateway = true
enable_flow_log    = true

cluster_version      = "1.35"
cluster_name         = "ai-bankapp-dev"
node_instance_type   = "m7i-flex.large"
image_tag_mutability = "MUTABLE"

desired_size = 1
min_size     = 1
max_size     = 2

endpoint_public_access  = true
endpoint_private_access = true
cluster_endpoint_public_access_cidrs = [
  "0.0.0.0/0"
]

system_desired_size      = 1
system_min_size          = 1
system_max_size          = 2
application_desired_size = 1
application_min_size     = 1
application_max_size     = 2
node_disk_size           = 50

argocd_server_insecure = true
