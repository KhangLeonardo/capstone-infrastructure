##########################################
# Virtual Private Cloud
##########################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.100.0.0/16"
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc"
    "TERRAFORM:Resource" = "aws_vpc"
    "TERRAFORM:Module"   = "vpc"
  })
}

##########################################
# Internet Gateway
##########################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-igw"
    "TERRAFORM:Resource" = "aws_internet_gateway"
    "TERRAFORM:Module"   = "vpc"
  })

  depends_on = [
    aws_vpc.vpc
  ]
}

##########################################
# Application Subnet Route Table
##########################################

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-app-rtb"
    "TERRAFORM:Resource" = "aws_route_table"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route" "app" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

##########################################
# Application Subnet in AZ 1
##########################################

resource "aws_subnet" "app_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.100.1.0/24"
  availability_zone_id    = var.primary_zone_id
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-app-1"
    "TERRAFORM:Resource" = "aws_subnet"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route_table_association" "app_1_association" {
  subnet_id      = aws_subnet.app_1.id
  route_table_id = aws_route_table.app.id
}

##########################################
# Application Subnet in AZ 2
##########################################

resource "aws_subnet" "app_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.100.2.0/24"
  availability_zone_id    = var.secondary_zone_id
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-app-2"
    "TERRAFORM:Resource" = "aws_subnet"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route_table_association" "app_2_association" {
  subnet_id      = aws_subnet.app_2.id
  route_table_id = aws_route_table.app.id
}

##########################################
# Server Subnet Route Table
##########################################

resource "aws_route_table" "server" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-server-rtb"
    "TERRAFORM:Resource" = "aws_route_table"
    "TERRAFORM:Module"   = "vpc"
  })
}

##########################################
# Server Subnet in AZ 1
##########################################

resource "aws_subnet" "server_1" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "10.100.3.0/24"
  availability_zone_id = var.primary_zone_id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-server-1"
    "TERRAFORM:Resource" = "aws_subnet"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route_table_association" "server_1_association" {
  subnet_id      = aws_subnet.server_1.id
  route_table_id = aws_route_table.server.id
}

##########################################
# Server Subnet in AZ 2
##########################################

resource "aws_subnet" "server_2" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "10.100.4.0/24"
  availability_zone_id = var.secondary_zone_id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-server-2"
    "TERRAFORM:Resource" = "aws_subnet"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route_table_association" "server_2_association" {
  subnet_id      = aws_subnet.server_2.id
  route_table_id = aws_route_table.server.id
}

##########################################
# DB Subnet Route Table
##########################################

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-db-rtb"
    "TERRAFORM:Resource" = "aws_route_table"
    "TERRAFORM:Module"   = "vpc"
  })
}

##########################################
# DB Subnet in AZ 1
##########################################

resource "aws_subnet" "db_1" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "10.100.5.0/24"
  availability_zone_id = var.primary_zone_id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-db-1"
    "TERRAFORM:Resource" = "aws_subnet"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route_table_association" "db_1_association" {
  subnet_id      = aws_subnet.db_1.id
  route_table_id = aws_route_table.db.id
}

##########################################
# DB Subnet in AZ 2
##########################################

resource "aws_subnet" "db_2" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "10.100.6.0/24"
  availability_zone_id = var.secondary_zone_id

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-vpc-db-2"
    "TERRAFORM:Resource" = "aws_subnet"
    "TERRAFORM:Module"   = "vpc"
  })
}

resource "aws_route_table_association" "db_2_association" {
  subnet_id      = aws_subnet.db_2.id
  route_table_id = aws_route_table.db.id
}
