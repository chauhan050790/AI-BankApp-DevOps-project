locals {
  node_groups = {
    system = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = length(var.system_node_instance_types) > 0 ? var.system_node_instance_types : [var.node_instance_type]
      disk_size      = var.node_disk_size
      capacity_type  = "ON_DEMAND"

      desired_size = coalesce(var.system_desired_size, var.desired_size)
      min_size     = coalesce(var.system_min_size, var.min_size)
      max_size     = coalesce(var.system_max_size, var.max_size)

      labels = {
        role = "system"
      }

      tags = {
        NodeGroup = "system"
      }

      update_config = {
        max_unavailable_percentage = 33
      }
    }

    application = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = length(var.application_node_instance_types) > 0 ? var.application_node_instance_types : [var.node_instance_type]
      disk_size      = var.node_disk_size
      capacity_type  = "ON_DEMAND"

      desired_size = coalesce(var.application_desired_size, var.desired_size)
      min_size     = coalesce(var.application_min_size, var.min_size)
      max_size     = coalesce(var.application_max_size, var.max_size)

      labels = {
        role = "application"
      }

      tags = {
        NodeGroup = "application"
      }

      update_config = {
        max_unavailable_percentage = 33
      }
    }
  }
}
