resource "helm_release" "this" {
  name             = "envoy-gateway"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  max_history      = 5

  values = [
    yamlencode({
      crds = {
        enabled = true
      }
      deployment = {
        replicas = var.replica_count
      }
    })
  ]
}
