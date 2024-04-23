module "vpc" {
  source = "../../modules/vpc"

  resource_name_prefix = local.resource_name_prefix
  tags                 = local.tags
  primary_zone_id      = "apse1-az1"
  secondary_zone_id    = "apse1-az2"
}

module "ec2" {
  source = "../../modules/ec2"

  resource_name_prefix     = local.resource_name_prefix
  tags                     = local.tags
  backend_system_subnet_id = module.vpc.app_1_subnet_id
  backend_system_subnet_az = "apse1-az1"
}
