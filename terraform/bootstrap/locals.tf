locals {
  common_tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}