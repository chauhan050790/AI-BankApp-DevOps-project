output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "argocd_namespace" {
  value = module.argocd.argocd_namespace
}

output "aws_load_balancer_controller_role_arn" {
  value = module.aws_load_balancer_controller.iam_role_arn
}
