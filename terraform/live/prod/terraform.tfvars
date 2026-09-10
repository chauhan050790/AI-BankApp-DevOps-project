project_name = "ai-bankapp"
environment  = "prod"
owner        = "Vipin Kumar"

aws_region = "ap-south-1"

vpc_cidr = "10.20.0.0/16"

azs = [
  "ap-south-1a",
  "ap-south-1b",
  "ap-south-1c"
]

public_subnets = [
  "10.20.1.0/24",
  "10.20.2.0/24",
  "10.20.3.0/24"
]

private_subnets = [
  "10.20.11.0/24",
  "10.20.12.0/24",
  "10.20.13.0/24"
]

intra_subnets = [
  "10.20.21.0/24",
  "10.20.22.0/24",
  "10.20.23.0/24"
]

single_nat_gateway = false
enable_flow_log    = true

cluster_name         = "ai-bankapp-prod"
cluster_version      = "1.35"
node_instance_type   = "m7i-flex.large"
image_tag_mutability = "IMMUTABLE"

desired_size = 3
min_size     = 3
max_size     = 8

endpoint_public_access               = false
endpoint_private_access              = true
cluster_endpoint_public_access_cidrs = []

system_desired_size      = 3
system_min_size          = 3
system_max_size          = 4
application_desired_size = 3
application_min_size     = 3
application_max_size     = 8
node_disk_size           = 100

argocd_server_insecure = false
