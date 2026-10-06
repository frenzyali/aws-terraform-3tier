variable "name" {
  description = "Name prefix for the ALB and its related resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "name must be 3-24 characters of lowercase letters, digits and hyphens (ALB names are limited to 32 characters including the suffix)."
  }
}

variable "vpc_id" {
  description = "ID of the VPC to create the ALB in."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB (at least two, in different AZs)."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An ALB needs at least two subnets in different Availability Zones."
  }
}

variable "target_port" {
  description = "Port the app listens on; used for the target group."
  type        = number
  default     = 3000

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "target_port must be a valid TCP port (1-65535)."
  }
}

variable "health_check_path" {
  description = "HTTP path the target group probes. The Flask app exposes /health."
  type        = string
  default     = "/health"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with '/'."
  }
}

variable "certificate_arn" {
  description = "ARN of an ACM certificate. When set, an HTTPS listener is created and HTTP redirects to it. Leave empty for HTTP only."
  type        = string
  default     = ""

  validation {
    condition     = var.certificate_arn == "" || can(regex("^arn:aws[a-z-]*:acm:", var.certificate_arn))
    error_message = "certificate_arn must be empty or an ACM certificate ARN (arn:aws:acm:...)."
  }
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB listeners. Defaults to the whole internet because this is a public web tier; restrict it for private demos."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.ingress_cidrs) > 0 && alltrue([for c in var.ingress_cidrs : can(cidrhost(c, 0))])
    error_message = "ingress_cidrs must be a non-empty list of valid CIDR blocks."
  }
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion. Turn on for prod."
  type        = bool
  default     = false
}
