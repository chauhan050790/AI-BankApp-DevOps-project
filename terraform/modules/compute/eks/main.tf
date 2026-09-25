module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.24.1"

  name               = local.cluster_name
  kubernetes_version = var.cluster_version

  endpoint_public_access                 = var.endpoint_public_access
  endpoint_private_access                = var.endpoint_private_access
  endpoint_public_access_cidrs           = var.cluster_endpoint_public_access_cidrs
  enabled_log_types                      = var.enabled_cluster_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days


  enable_cluster_creator_admin_permissions = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.control_plane_subnets

  addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        nodeAgent = {
          healthProbeBindAddr = "8163"
          metricsBindAddr     = "8162"
        }
      })
    }

    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    eks-pod-identity-agent = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"

      pod_identity_association = [
        {
          role_arn        = aws_iam_role.ebs_csi.arn
          service_account = "ebs-csi-controller-sa"
        }
      ]
    }
  }


  eks_managed_node_groups = local.node_groups

  enable_irsa = local.enable_irsa

  create_kms_key          = var.enable_cluster_encryption
  enable_kms_key_rotation = var.enable_cluster_encryption
  encryption_config       = var.enable_cluster_encryption ? { resources = ["secrets"] } : null
  authentication_mode     = "API_AND_CONFIG_MAP"

  tags = local.common_tags
}
