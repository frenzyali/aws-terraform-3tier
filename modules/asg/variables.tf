variable "name" {
  description = "Name prefix for the app tier resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "name must be 3-24 characters of lowercase letters, digits and hyphens."
  }
}

variable "vpc_id" {
  description = "ID of the VPC the app security group is created in."
  type        = string
}

variable "subnet_ids" {
  description = "Private app subnet IDs the ASG launches instances into."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Use at least two subnets in different AZs so the ASG can survive an AZ failure."
  }
}

variable "alb_security_group_id" {
  description = "Security group of the ALB; the only source allowed to reach the app port."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register instances in."
  type        = string
}

variable "app_image" {
  description = "Container image to run, e.g. 'your-dockerhub-user/3tier-app:1.0.0'. Prefer an immutable tag over ':latest'."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._/:@-]*$", var.app_image)) && !strcontains(var.app_image, " ")
    error_message = "app_image must be a valid container image reference with no spaces."
  }
}

variable "app_port" {
  description = "Host port the container is published on; must match the ALB target port. The Flask app listens on 3000 inside the container."
  type        = number
  default     = 3000

  validation {
    condition     = var.app_port >= 1024 && var.app_port <= 65535
    error_message = "app_port must be an unprivileged port (1024-65535)."
  }
}

variable "db_host" {
  description = "Hostname of the database (RDS endpoint address)."
  type        = string
}

variable "db_name" {
  description = "Name of the database the app connects to."
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB 'username' and 'password' (RDS-managed master secret)."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:secretsmanager:", var.db_secret_arn))
    error_message = "db_secret_arn must be a Secrets Manager secret ARN."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the app tier (x86_64)."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = !can(regex("^[a-z]+[0-9]+g[a-z]*\\.", var.instance_type))
    error_message = "The AMI is x86_64; use a non-Graviton instance type (e.g. t3.micro, m6i.large)."
  }
}

variable "root_volume_size_gb" {
  description = "Size of the encrypted gp3 root volume in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size_gb >= 8
    error_message = "root_volume_size_gb must be at least 8."
  }
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1."
  }
}

variable "desired_capacity" {
  description = "Initial number of instances (changes after creation are left to the scaling policy)."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_capacity >= 1
    error_message = "desired_capacity must be at least 1."
  }
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= 1
    error_message = "max_size must be at least 1."
  }
}

variable "cpu_target_percent" {
  description = "Average CPU utilisation the target-tracking policy aims for."
  type        = number
  default     = 60

  validation {
    condition     = var.cpu_target_percent > 10 && var.cpu_target_percent < 90
    error_message = "cpu_target_percent must be between 10 and 90."
  }
}
