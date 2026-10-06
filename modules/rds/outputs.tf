output "address" {
  description = "DNS address of the database (no port)."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Port the database listens on."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.this.db_name
}

output "security_group_id" {
  description = "ID of the DB security group."
  value       = aws_security_group.db.id
}

output "master_user_secret_arn" {
  description = "ARN (not the value) of the Secrets Manager secret holding the master credentials."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
