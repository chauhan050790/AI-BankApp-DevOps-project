variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "owner" {
  description = "Project Owner"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Value must be MUTABLE or IMMUTABLE."
  }
}
