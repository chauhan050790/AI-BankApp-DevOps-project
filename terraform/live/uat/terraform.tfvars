project_name = "ai-bankapp"
environment  = "uat"
owner        = "Vipin Kumar"

aws_region = "ap-south-1"

vpc_cidr = "10.10.0.0/16"

azs = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnets = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnets = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

intra_subnets = [
  "10.10.21.0/24",
  "10.10.22.0/24"
]

single_nat_gateway = false
enable_flow_log    = true

cluster_name         = "ai-bankapp-uat"
cluster_version      = "1.35"
node_instance_type   = "c7i-flex.large"
image_tag_mutability = "IMMUTABLE"

desired_size = 2
min_size     = 2
max_size     = 4

endpoint_public_access  = true
endpoint_private_access = true
cluster_endpoint_public_access_cidrs = [
  "0.0.0.0/0"
]

system_desired_size      = 1
system_min_size          = 1
system_max_size          = 1
application_desired_size = 1
application_min_size     = 1
application_max_size     = 1
node_disk_size           = 80

argocd_server_insecure       = false
argocd_high_availability     = false
metrics_server_replica_count = 2
