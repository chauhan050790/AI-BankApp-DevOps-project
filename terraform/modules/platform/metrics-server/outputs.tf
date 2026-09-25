output "release_name" {
  value = helm_release.metrics_server.name
}

output "status" {
  value = helm_release.metrics_server.status
}
