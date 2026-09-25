resource "helm_release" "this" {
  name            = local.helm_release
  repository      = "https://aws.github.io/eks-charts"
  chart           = "aws-load-balancer-controller"
  version         = var.chart_version
  namespace       = local.namespace
  atomic          = true
  cleanup_on_fail = true
  wait            = true
  wait_for_jobs   = true
  timeout         = 900
  max_history     = 5

  values = [
    yamlencode({
      clusterName  = var.cluster_name
      region       = var.region
      vpcId        = var.vpc_id
      replicaCount = var.replica_count
      serviceAccount = {
        create = true
        name   = local.service_account
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
        }
      }
      defaultTargetType            = "ip"
      enablePodReadinessGateInject = true
      createIngressClassResource   = true
      defaultTags                  = local.common_tags
      podDisruptionBudget = {
        maxUnavailable = var.replica_count > 1 ? 1 : null
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          memory = "512Mi"
        }
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.this]
}
