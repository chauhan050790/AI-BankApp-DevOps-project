resource "helm_release" "metrics_server" {

  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server"
  chart            = "metrics-server"
  version          = var.chart_version
  namespace        = "kube-system"
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  timeout          = 600
  max_history      = 5

  values = [
    yamlencode({
      replicas = var.replica_count
      podDisruptionBudget = {
        enabled      = var.replica_count > 1
        minAvailable = var.replica_count > 1 ? 1 : null
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          memory = "400Mi"
        }
      }
      topologySpreadConstraints = var.replica_count > 1 ? [
        {
          maxSkew           = 1
          topologyKey       = "kubernetes.io/hostname"
          whenUnsatisfiable = "ScheduleAnyway"
          labelSelector = {
            matchLabels = {
              "app.kubernetes.io/name" = "metrics-server"
            }
          }
        }
      ] : []
    })
  ]
}
