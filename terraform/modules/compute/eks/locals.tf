locals {

  cluster_name = coalesce(var.cluster_name, "${var.project_name}-${var.environment}")

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }

}
