output "role_arn" {
  description = "ARN of the GitHub Actions ECR push role"
  value       = aws_iam_role.this.arn
}
