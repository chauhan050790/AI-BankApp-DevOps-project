variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC Provider ARN"
  type        = string
}

variable "cluster_oidc_provider" {
  description = "OIDC Provider URL"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.13.4"
}
