module "vpc" {

  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner

  vpc_cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  intra_subnets   = var.intra_subnets

  single_nat_gateway = var.single_nat_gateway
  enable_flow_log    = var.enable_flow_log
}


module "ecr" {

  source = "../../modules/compute/ecr"

  project_name         = var.project_name
  environment          = var.environment
  owner                = var.owner
  image_tag_mutability = var.image_tag_mutability

}


module "eks" {

  source = "../../modules/compute/eks"

  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  control_plane_subnets = module.vpc.intra_subnets

  node_instance_type = var.node_instance_type
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size

  endpoint_public_access               = var.endpoint_public_access
  endpoint_private_access              = var.endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  system_node_instance_types      = var.system_node_instance_types
  application_node_instance_types = var.application_node_instance_types
  system_desired_size             = var.system_desired_size
  system_min_size                 = var.system_min_size
  system_max_size                 = var.system_max_size
  application_desired_size        = var.application_desired_size
  application_min_size            = var.application_min_size
  application_max_size            = var.application_max_size
  node_disk_size                  = var.node_disk_size
}

module "metrics_server" {
  source = "../../modules/platform/metrics-server"

  depends_on = [
    module.eks
  ]
}

module "argocd" {
  source = "../../modules/platform/argocd"

  server_insecure = var.argocd_server_insecure

  depends_on = [
    module.eks
  ]
}

module "aws_load_balancer_controller" {

  source = "../../modules/platform/aws-load-balancer-controller"

  project_name = var.project_name
  environment  = var.environment

  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_oidc_provider     = module.eks.oidc_provider

  vpc_id = module.vpc.vpc_id
  region = var.aws_region

  tags = local.common_tags

  depends_on = [
    module.eks
  ]
}
