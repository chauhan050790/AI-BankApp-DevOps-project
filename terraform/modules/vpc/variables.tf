variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "owner" {
  description = "Project Owner"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public Subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnets"
  type        = list(string)
}

variable "intra_subnets" {
  description = "Intra Subnets"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC flow logs to CloudWatch"
  type        = bool
  default     = true
}
