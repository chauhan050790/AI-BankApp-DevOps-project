variable "release_name" {
  description = "Helm release name; it must match ServiceMonitor release labels"
  type        = string
  default     = "kube-prometheus"
}

variable "namespace" {
  description = "Namespace for Prometheus and Grafana"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Pinned kube-prometheus-stack chart version"
  type        = string
  default     = "91.8.0"
}

variable "storage_class" {
  description = "Persistent storage class"
  type        = string
  default     = "gp3"
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent volume size"
  type        = string
  default     = "5Gi"
}

variable "grafana_storage_size" {
  description = "Grafana persistent volume size"
  type        = string
  default     = "2Gi"
}

variable "prometheus_retention" {
  description = "Metric retention period for the dev stack"
  type        = string
  default     = "3d"
}
