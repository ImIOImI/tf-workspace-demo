locals {
  workspace = terraform.workspace

  subnet        = module.global.subnet
  region        = module.global.region
  country       = module.global.country
  environment   = module.global.environment
  timezone      = module.global.timezone
  time-offset   = module.global.time-offset
  k8s-max-nodes = module.global.k8s-max-nodes
  hub-subnet    = module.global.hub-subnet
}

module "global" {
  source = "./modules/global"
  context = local.workspace
}