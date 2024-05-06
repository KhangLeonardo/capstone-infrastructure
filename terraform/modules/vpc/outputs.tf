output "id" {
  value = aws_vpc.vpc.id
}

output "arn" {
  value = aws_vpc.vpc.arn
}

output "instance_tenancy" {
  value = aws_vpc.vpc.instance_tenancy
}

output "enable_dns_support" {
  value = aws_vpc.vpc.enable_dns_support
}

output "enable_dns_hostnames" {
  value = aws_vpc.vpc.enable_dns_hostnames
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "app_1_subnet_id" {
  value = aws_subnet.app_1.id
}

output "app_2_subnet_id" {
  value = aws_subnet.app_2.id
}

output "server_1_subnet_id" {
  value = aws_subnet.server_1.id
}

output "server_2_subnet_id" {
  value = aws_subnet.server_2.id
}

output "db_1_subnet_id" {
  value = aws_subnet.db_1.id
}

output "db_2_subnet_id" {
  value = aws_subnet.db_2.id
}

output "vpc_s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}
