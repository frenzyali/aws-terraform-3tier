variable "aws_region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name, used in resource names and the Project tag."
  type        = string
  default     = "aws-terraform-3tier"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.project))
    error_message = "project must be 3-30 characters of lowercase letters, digits and hyphens."
  }
}

variable "state_bucket_name" {
  description = "Globally unique name for the S3 state bucket (S3 names are shared across all AWS accounts)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}$", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid S3 bucket name (3-63 chars, lowercase letters, digits, dots, hyphens)."
  }
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  type        = string
  default     = "aws-terraform-3tier-locks"
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep old state versions before they expire."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 7
    error_message = "Keep at least 7 days of state history."
  }
}
