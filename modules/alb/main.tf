locals {
  https_enabled = var.certificate_arn != ""
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "Public ALB: HTTP/HTTPS in from allowed CIDRs"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-alb-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  #checkov:skip=CKV_AWS_260:Public web tier: port 80 must accept the internet; it redirects to HTTPS when a certificate is supplied
  for_each = toset(var.ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTP from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = local.https_enabled ? toset(var.ingress_cidrs) : toset([])

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = each.value
}

# Egress is deliberately not defined here. The root module adds a single rule
# allowing the target port to the app security group, which avoids a
# module-level dependency cycle (alb <-> asg) and keeps the SG chain in one place.

resource "aws_lb" "this" {
  #checkov:skip=CKV_AWS_150:Deletion protection is a variable; enabled in the prod example, off in dev so it can be destroyed
  #checkov:skip=CKV_AWS_91:Access logs need a dedicated S3 bucket and policy; listed under known limitations
  #checkov:skip=CKV2_AWS_20:HTTPS is optional by design (no ACM certificate in a demo); with certificate_arn set, HTTP redirects to HTTPS
  #checkov:skip=CKV2_AWS_28:AWS WAF adds a recurring cost and is out of scope for this demo
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = 60

  tags = { Name = "${var.name}-alb" }
}

resource "aws_lb_target_group" "app" {
  #checkov:skip=CKV_AWS_378:TLS terminates at the ALB; traffic to targets stays inside private subnets over the chained security groups
  name_prefix = "app-"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  deregistration_delay = 30

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "${var.name}-app-tg" }

  lifecycle {
    create_before_destroy = true
  }
}

# Without a certificate the HTTP listener forwards to the app; with one it
# redirects everything to HTTPS.
resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_103:Port 80 listener has no TLS; the HTTPS listener enforces the TLS 1.2+ policy ELBSecurityPolicy-TLS13-1-2-2021-06
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.https_enabled ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.https_enabled ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
  }
}

resource "aws_lb_listener" "https" {
  count = local.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
