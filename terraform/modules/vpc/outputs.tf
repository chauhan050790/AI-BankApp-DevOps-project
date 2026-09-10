output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnets
}

output "intra_subnets" {
  description = "Intra Subnet IDs"
  value       = module.vpc.intra_subnets
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}