variable "chart_version" {
  description = "metrics-server Helm chart version"
  type        = string
  default     = "3.14.0"
}

variable "replica_count" {
  description = "Number of metrics-server replicas"
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}
