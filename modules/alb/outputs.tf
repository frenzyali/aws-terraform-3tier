output "dns_name" {
  description = "Public DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Route 53 zone ID of the ALB, for alias records."
  value       = aws_lb.this.zone_id
}

output "arn_suffix" {
  description = "ALB ARN suffix, for CloudWatch metric dimensions."
  value       = aws_lb.this.arn_suffix
}

output "security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the target group the ASG registers instances into."
  value       = aws_lb_target_group.app.arn
}

output "https_enabled" {
  description = "Whether the HTTPS listener was created."
  value       = local.https_enabled
}
