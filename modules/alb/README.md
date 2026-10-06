# modules/alb

Internet-facing Application Load Balancer, its security group (80/443 ingress only), an instance target group with an HTTP health check, and listeners.

- No certificate: port 80 forwards to the target group.
- `certificate_arn` set: port 443 terminates TLS (TLS 1.3/1.2 policy) and port 80 redirects to it.

The ALB-to-app egress rule lives in the root module; see the comment in `main.tf`.

## Inputs / outputs

See [variables.tf](variables.tf) and [outputs.tf](outputs.tf). `name`, `vpc_id` and `subnet_ids` are required.
