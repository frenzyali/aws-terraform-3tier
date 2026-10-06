locals {
  name     = "${var.project}-${var.environment}"
  app_port = 3000 # Flask listens on 3000 in the app image (see the 3-tier-app-deployment repo)
}

module "network" {
  source = "./modules/network"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

module "alb" {
  source = "./modules/alb"

  name                       = local.name
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.public_subnet_ids
  target_port                = local.app_port
  certificate_arn            = var.certificate_arn
  ingress_cidrs              = var.alb_ingress_cidrs
  enable_deletion_protection = var.alb_deletion_protection
}

module "rds" {
  source = "./modules/rds"

  name                       = local.name
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.db_subnet_ids
  allowed_security_group_ids = [module.asg.security_group_id]
  instance_class             = var.db_instance_class
  allocated_storage_gb       = var.db_allocated_storage_gb
  db_name                    = var.db_name
  multi_az                   = var.db_multi_az
  backup_retention_days      = var.db_backup_retention_days
  deletion_protection        = var.db_deletion_protection
  skip_final_snapshot        = var.db_skip_final_snapshot
}

module "asg" {
  source = "./modules/asg"

  name                  = local.name
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.app_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  app_image             = var.app_image
  app_port              = local.app_port
  instance_type         = var.app_instance_type
  min_size              = var.app_min_size
  desired_capacity      = var.app_desired_capacity
  max_size              = var.app_max_size
  db_host               = module.rds.address
  db_name               = module.rds.db_name
  db_secret_arn         = module.rds.master_user_secret_arn
}

# ---------------------------------------------------------------- SG chain
# Ingress side:  internet -> ALB (80/443)  [alb module]
#                ALB SG   -> app (3000)    [asg module]
#                app SG   -> DB (3306)     [rds module]
# Egress side is wired here, where both security group IDs are known, so no
# module needs to depend on its downstream neighbour.

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = module.alb.security_group_id
  description                  = "ALB to app tier on the app port"
  ip_protocol                  = "tcp"
  from_port                    = local.app_port
  to_port                      = local.app_port
  referenced_security_group_id = module.asg.security_group_id
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = module.asg.security_group_id
  description                  = "App tier to MySQL"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = module.rds.security_group_id
}
