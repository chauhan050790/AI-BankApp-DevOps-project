variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "10.9.2"
}

variable "server_insecure" {
  description = "Run Argo CD server without its own TLS. Use only behind trusted TLS termination."
  type        = bool
  default     = false
}

variable "high_availability" {
  description = "Run the Argo CD control-plane components and Redis in high-availability mode"
  type        = bool
  default     = false
}
