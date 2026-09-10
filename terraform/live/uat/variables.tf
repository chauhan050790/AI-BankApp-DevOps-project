variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "intra_subnets" {
  type = list(string)
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_flow_log" {
  type    = bool
  default = true
}

variable "cluster_version" {
  type = string
}

variable "node_instance_type" {
  type = string
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "system_node_instance_types" {
  type    = list(string)
  default = []
}

variable "application_node_instance_types" {
  type    = list(string)
  default = []
}

variable "system_desired_size" {
  type    = number
  default = null
}

variable "system_min_size" {
  type    = number
  default = null
}

variable "system_max_size" {
  type    = number
  default = null
}

variable "application_desired_size" {
  type    = number
  default = null
}

variable "application_min_size" {
  type    = number
  default = null
}

variable "application_max_size" {
  type    = number
  default = null
}

variable "node_disk_size" {
  type    = number
  default = 50
}

variable "argocd_server_insecure" {
  type    = bool
  default = false
}
