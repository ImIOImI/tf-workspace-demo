locals {
  workspace = terraform.workspace

  organisation-id = module.global.organisation-id
  network         = module.global.network
  subnet          = module.global.subnet
  region          = module.global.region
  country         = module.global.country
  environment     = module.global.environment
  timezone        = module.global.timezone
  time-offset     = module.global.time-offset
  k8s-max-nodes   = module.global.k8s-max-nodes
  hub-subnet      = module.global.hub-subnet
  env-timezone    = module.global.env-timezone
  location        = module.global.location
}

module "global" {
  source  = "./modules/global"
  context = local.workspace
}
