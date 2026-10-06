resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  description = "DB tier: MySQL in from the app tier only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-db-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_app" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.db.id
  description                  = "MySQL from app security group"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = each.value
}

# No egress rules: a database has no reason to initiate outbound connections.

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db"
  subnet_ids = var.subnet_ids

  tags = { Name = "${var.name}-db-subnets" }
}

resource "aws_db_instance" "this" {
  #checkov:skip=CKV_AWS_118:Enhanced monitoring needs an extra IAM role and per-minute cost; CloudWatch metrics and log exports are enabled instead
  #checkov:skip=CKV_AWS_353:Performance Insights is not offered on the micro/small burstable classes used here
  identifier = "${var.name}-mysql"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.max_allocated_storage_gb
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.master_username

  # RDS creates and rotates the master password in Secrets Manager. It is never
  # passed through Terraform variables and never appears in state or outputs.
  manage_master_user_password = true

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  port                   = 3306

  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["error", "slowquery"]

  backup_retention_period    = var.backup_retention_days
  backup_window              = "03:00-04:00"
  maintenance_window         = "sun:04:30-sun:05:30"
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-mysql-final"

  tags = { Name = "${var.name}-mysql" }
}
