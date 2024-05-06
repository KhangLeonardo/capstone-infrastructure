module "vpc" {
  source = "../../modules/vpc"

  resource_name_prefix = local.resource_name_prefix
  tags                 = local.tags
  primary_zone_id      = "apse1-az1"
  secondary_zone_id    = "apse1-az2"
}

module "jenkins" {
  source = "../../modules/jenkins"

  resource_name_prefix = local.resource_name_prefix
  tags                 = local.tags
  vpc_id               = module.vpc.id
  public_subnet_ids    = [module.vpc.app_1_subnet_id, module.vpc.app_2_subnet_id]
  vpc_s3_endpoint      = module.vpc.vpc_s3_endpoint_id
  enable_eip           = true
}

# module "ec2" {
#   source = "../../modules/ec2"

#   resource_name_prefix     = local.resource_name_prefix
#   tags                     = local.tags
#   vpc_id                   = module.vpc.id
#   backend_system_subnet_id = module.vpc.app_1_subnet_id
#   backend_system_subnet_az = "ap-southeast-1a"
# }
