locals {

  namespace = "kube-system"

  service_account = "aws-load-balancer-controller"

  helm_release = "aws-load-balancer-controller"

  common_tags = merge(
    var.tags,
    {
      Component   = "aws-load-balancer-controller"
      Environment = var.environment
      Terraform   = "true"
    }
  )

}