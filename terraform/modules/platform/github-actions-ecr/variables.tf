variable "role_name" {
  description = "Name of the GitHub Actions IAM role"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository the workflow may push to"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner name"
  type        = string
}

variable "github_owner_id" {
  description = "Immutable GitHub repository owner ID"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "github_repository_id" {
  description = "Immutable GitHub repository ID"
  type        = string
}

variable "github_branch" {
  description = "Only branch allowed to assume the role"
  type        = string
}

variable "tags" {
  description = "Tags applied to the IAM role"
  type        = map(string)
  default     = {}
}
