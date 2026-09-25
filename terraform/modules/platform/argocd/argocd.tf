# Argo CD remains private by default. Use kubectl port-forward or place it
# behind a separately authenticated TLS ingress when remote access is needed.

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
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
      global = {
        logging = {
          format = "json"
        }
        networkPolicy = {
          create = true
        }
      }
      crds = {
        install = true
        keep    = true
      }
      configs = {
        params = {
          "server.insecure" = var.server_insecure
        }
      }
      controller = {
        replicas = var.high_availability ? 2 : 1
        pdb = {
          enabled      = var.high_availability
          minAvailable = 1
        }
        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }
          limits = {
            memory = "1Gi"
          }
        }
      }
      server = {
        replicas = var.high_availability ? 2 : 1
        service = {
          type = "ClusterIP"
        }
        pdb = {
          enabled      = var.high_availability
          minAvailable = 1
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
      }
      repoServer = {
        replicas = var.high_availability ? 2 : 1
        pdb = {
          enabled      = var.high_availability
          minAvailable = 1
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            memory = "1Gi"
          }
        }
      }
      applicationSet = {
        replicas = var.high_availability ? 2 : 1
        pdb = {
          enabled      = var.high_availability
          minAvailable = 1
        }
      }
      redis = {
        enabled = !var.high_availability
      }
      "redis-ha" = {
        enabled = var.high_availability
      }
    })
  ]
}
