output "state_bucket_name" {
  description = "Name of the S3 bucket to use in the main stack's backend configuration."
  value       = aws_s3_bucket.state.id
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table to use in the main stack's backend configuration."
  value       = aws_dynamodb_table.locks.name
}

output "backend_config_snippet" {
  description = "Ready-to-paste backend block for the main stack (copy to backend.tf)."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.state.id}"
        key            = "ENV/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.locks.name}"
        encrypt        = true
      }
    }
  EOT
}
