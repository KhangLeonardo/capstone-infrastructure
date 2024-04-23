module "vpc" {
  source = "../../modules/vpc"

  resource_name_prefix = local.resource_name_prefix
  tags                 = local.tags
  primary_zone_id      = "apse1-az1"
  secondary_zone_id    = "apse1-az2"
}
