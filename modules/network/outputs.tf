output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (ALB, NAT)."
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "IDs of the private app subnets."
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = aws_subnet.db[*].id
}

output "availability_zones" {
  description = "Availability Zones used by the subnets."
  value       = local.azs
}

output "nat_gateway_count" {
  description = "Number of NAT gateways created."
  value       = local.nat_count
}
