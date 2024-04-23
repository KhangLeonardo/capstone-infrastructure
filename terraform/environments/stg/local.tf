locals {
  # cap-aws-mykidz-dev
  ## prefix = cap
  ## provider = aws
  ## project = mykidz
  ## env = dev
  resource_name_prefix = "${var.prefix}-${var.tags.provider_name}-${var.tags.project_name}-${var.tags.environment_name}"

  prefix_separator = "-"

  tags = {
    "CAPSTONE:Provider"    = var.tags.provider_name
    "CAPSTONE:Project"     = var.tags.project_name
    "CAPSTONE:Environment" = var.tags.environment_name
    "CAPSTONE:Owner"       = var.tags.owner
  }
}
