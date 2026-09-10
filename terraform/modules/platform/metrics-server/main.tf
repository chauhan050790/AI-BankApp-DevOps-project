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

  timeout = 600
}
