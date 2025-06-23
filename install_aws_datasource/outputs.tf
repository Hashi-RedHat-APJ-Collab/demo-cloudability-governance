output "role_arn" {
  description = "The ARN of the created IAM role"
  value       = awscc_iam_role.cloudability_role.arn
}

output "role_name" {
  description = "The name of the created IAM role"
  value       = awscc_iam_role.cloudability_role.role_name
}
