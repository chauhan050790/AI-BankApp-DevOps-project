output "iam_role_arn" {
  value = aws_iam_role.this.arn
}

output "helm_release_name" {
  value = helm_release.this.name
}

output "status" {
  value = helm_release.this.status
}
