output "security_group_id" {
  description = "ID of the app tier security group."
  value       = aws_security_group.app.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the launch template."
  value       = aws_launch_template.app.id
}

output "instance_role_name" {
  description = "Name of the IAM role attached to app instances."
  value       = aws_iam_role.app.name
}
