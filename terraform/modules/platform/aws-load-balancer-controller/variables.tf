variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "ARN of the EKS cluster IAM OIDC provider"
  type        = string
}

variable "cluster_oidc_provider" {
  description = "Issuer URL of the EKS cluster IAM OIDC provider"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID containing the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS Region containing the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Tags applied to IAM and controller-managed AWS resources"
  type        = map(string)
  default     = {}
}

variable "chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "3.5.0"
}

variable "replica_count" {
  description = "Number of AWS Load Balancer Controller replicas"
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}
