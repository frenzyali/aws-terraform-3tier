# modules/network

VPC spread across 2-3 AZs with three subnet tiers (public, private app, private DB), an internet gateway, per-AZ private route tables, optional NAT (single shared or per-AZ), and optional VPC flow logs.

The DB route table has no default route, so database subnets cannot reach the internet in either direction.

## Inputs

See [variables.tf](variables.tf). Only `name` is required.

## Outputs

See [outputs.tf](outputs.tf): VPC ID/CIDR, subnet IDs per tier, AZ names, NAT count.
