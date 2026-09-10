variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "owner" {
  description = "Project owner"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. Defaults to project-environment when null."
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "control_plane_subnets" {
  description = "Control plane subnet IDs"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "m7i-flex.large"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS API endpoint"
  type        = bool
  default     = false
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS API endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retention period for EKS control plane logs"
  type        = number
  default     = 90
}

variable "enable_cluster_encryption" {
  description = "Enable KMS envelope encryption for Kubernetes secrets"
  type        = bool
  default     = true
}

variable "system_node_instance_types" {
  description = "Instance types for the system node group"
  type        = list(string)
  default     = []
}

variable "application_node_instance_types" {
  description = "Instance types for the application node group"
  type        = list(string)
  default     = []
}

variable "system_desired_size" {
  description = "Desired system node count"
  type        = number
  default     = null
}

variable "system_min_size" {
  description = "Minimum system node count"
  type        = number
  default     = null
}

variable "system_max_size" {
  description = "Maximum system node count"
  type        = number
  default     = null
}

variable "application_desired_size" {
  description = "Desired application node count"
  type        = number
  default     = null
}

variable "application_min_size" {
  description = "Minimum application node count"
  type        = number
  default     = null
}

variable "application_max_size" {
  description = "Maximum application node count"
  type        = number
  default     = null
}

variable "node_disk_size" {
  description = "Managed node group disk size in GiB"
  type        = number
  default     = 50
}
