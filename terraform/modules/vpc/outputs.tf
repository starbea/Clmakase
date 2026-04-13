output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "List of private application subnet IDs"
  value       = values(aws_subnet.private)[*].id
}

output "private_data_subnet_ids" {
  description = "List of private data subnet IDs"
  value       = values(aws_subnet.private_data)[*].id
}

output "private_subnet_ids_by_key" {
  description = "Private subnet IDs by key"
  value       = { for k, subnet in aws_subnet.private : k => subnet.id }
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = values(aws_nat_gateway.this)[*].id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = values(aws_route_table.private)[*].id
}