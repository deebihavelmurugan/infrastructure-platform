output "role_arn" {
  value       = aws_iam_role.workload.arn
  description = "ARN of the provisioned IAM workload role"
}

output "bucket_names" {
  value       = [for b in aws_s3_bucket.bucket : b.id]
  description = "List of bucket names provisioned for the team"
}
