variable "namespace" {
  description = "Namespace used by the Envoy Gateway control plane"
  type        = string
  default     = "envoy-gateway-system"
}

variable "chart_version" {
  description = "Envoy Gateway Helm chart version"
  type        = string
  default     = "v1.9.1"
}

variable "replica_count" {
  description = "Number of Envoy Gateway controller replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}
