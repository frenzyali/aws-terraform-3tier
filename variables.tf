variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name; prefix for resource names and the Project tag."
  type        = string
  default     = "aws-terraform-3tier"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project))
    error_message = "project must start with a letter and be 3-21 characters of lowercase letters, digits and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev or prod); suffix for resource names and the Environment tag."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

# ---------------------------------------------------------------- network

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones (2 or 3)."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) for outbound access from the private app tier. Disable only if you provide another egress path (e.g. VPC endpoints and a private registry)."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway (cheap) instead of one per AZ (resilient)."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------- web / app

variable "certificate_arn" {
  description = "ACM certificate ARN. When set, the ALB serves HTTPS and redirects HTTP to it."
  type        = string
  default     = ""
}

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_deletion_protection" {
  description = "Enable ALB deletion protection."
  type        = bool
  default     = false
}

variable "app_image" {
  description = "Container image for the app tier, e.g. 'your-dockerhub-user/3tier-app:1.0.0'."
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for the app tier."
  type        = string
  default     = "t3.micro"
}

variable "app_min_size" {
  description = "Minimum number of app instances."
  type        = number
  default     = 2
}

variable "app_desired_capacity" {
  description = "Initial number of app instances."
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "Maximum number of app instances."
  type        = number
  default     = 4
}

# ---------------------------------------------------------------- data

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage_gb" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name; must match the app's DB_NAME."
  type        = string
  default     = "testdb"
}

variable "db_multi_az" {
  description = "Run RDS Multi-AZ (standby in a second AZ)."
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  description = "RDS automated backup retention in days."
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip the final RDS snapshot on destroy."
  type        = bool
  default     = true
}
