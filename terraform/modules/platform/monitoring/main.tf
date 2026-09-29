resource "helm_release" "this" {
  name             = var.release_name
  repository       = "oci://ghcr.io/prometheus-community/charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 1200
  max_history      = 5

  values = [
    yamlencode({
      crds = {
        enabled = true
      }

      defaultRules = {
        create = false
      }

      alertmanager = {
        enabled = false
      }

      kubeControllerManager = {
        enabled = false
      }

      kubeEtcd = {
        enabled = false
      }

      kubeScheduler = {
        enabled = false
      }

      grafana = {
        enabled = true
        service = {
          type = "ClusterIP"
        }
        sidecar = {
          datasources = {
            alertmanager = {
              enabled = false
            }
          }
        }
        persistence = {
          enabled          = true
          type             = "pvc"
          storageClassName = var.storage_class
          accessModes      = ["ReadWriteOnce"]
          size             = var.grafana_storage_size
        }
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            memory = "384Mi"
          }
        }
      }

      prometheusOperator = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            memory = "256Mi"
          }
        }
      }

      kube-state-metrics = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            memory = "256Mi"
          }
        }
      }

      prometheus-node-exporter = {
        resources = {
          requests = {
            cpu    = "20m"
            memory = "32Mi"
          }
          limits = {
            memory = "128Mi"
          }
        }
      }

      prometheus = {
        service = {
          type = "ClusterIP"
        }
        prometheusSpec = {
          replicas                                = 1
          retention                               = var.prometheus_retention
          scrapeInterval                          = "30s"
          evaluationInterval                      = "30s"
          walCompression                          = true
          enableAdminAPI                          = false
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
          ruleSelectorNilUsesHelmValues           = false
          probeSelectorNilUsesHelmValues          = false
          scrapeConfigSelectorNilUsesHelmValues   = false
          serviceMonitorSelector                  = {}
          serviceMonitorNamespaceSelector         = {}
          podMonitorSelector                      = {}
          podMonitorNamespaceSelector             = {}
          resources = {
            requests = {
              cpu    = "200m"
              memory = "384Mi"
            }
            limits = {
              memory = "1Gi"
            }
          }
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          }
        }
      }
    })
  ]
}
