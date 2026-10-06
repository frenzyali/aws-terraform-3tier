output "alb_dns_name" {
  description = "Public DNS name of the load balancer. Browse to http://<this>/health once instances are healthy."
  value       = module.alb.dns_name
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "autoscaling_group_name" {
  description = "Name of the app Auto Scaling Group."
  value       = module.asg.autoscaling_group_name
}

output "db_address" {
  description = "Private DNS address of the RDS instance."
  value       = module.rds.address
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB credentials (the ARN only, never the value)."
  value       = module.rds.master_user_secret_arn
}
