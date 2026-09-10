variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "8.5.8"
}

variable "server_insecure" {
  description = "Run Argo CD server without its own TLS. Use only behind trusted TLS termination."
  type        = bool
  default     = false
}
