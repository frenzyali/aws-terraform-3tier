# modules/rds

RDS MySQL in private DB subnets: storage encrypted, not publicly accessible, Multi-AZ via `multi_az`, and the master password generated and stored by RDS in Secrets Manager (`manage_master_user_password = true`).

Ingress to 3306 is allowed only from the security groups in `allowed_security_group_ids`. The module defines no egress rules.

## Inputs / outputs

See [variables.tf](variables.tf) and [outputs.tf](outputs.tf). The only secret-related output is the secret's ARN.
