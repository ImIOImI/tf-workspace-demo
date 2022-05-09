locals {
  organisation-id = "06288276-e890-4c3d-bfe7-bdb96cfd304b"
  network         = "10.0.0.0/8"

  contexts = {
    default = {
      environment = "dev"
      region      = "east"
      country     = "us"
      subnet      = cidrsubnet(local.network,  16, 0)
    }
    dev = {
      subnet = cidrsubnet(local.network,  16, 1)
    }
    infra = {
      subnet = cidrsubnet(local.network, 16, 2)
    }
    stage-east = {
      environment = "stage"
      subnet      = cidrsubnet(local.network,  16, 3)
    }
    stage-west = {
      environment = "stage"
      region      = "west"
      subnet      = cidrsubnet(local.network,  16, 4)
    }
    prod-east = {
      environment = "prod"
      subnet      = cidrsubnet(local.network,  16, 5)
    }
    prod-west = {
      environment = "prod"
      region      = "west"
      subnet      = cidrsubnet(local.network,  16, 6)
    }
  }
  workspace = terraform.workspace

  //if the workspace is contained in the context map, use it, otherwise use the default context
  ctxtvar  = contains(keys(local.contexts), local.workspace) ? local.workspace : "default"
  //use the values in the default context as defaults and override them with other values
  ctxtvars = merge(local.contexts["default"], local.contexts[local.ctxtvar])

  subnet      = local.ctxtvars["subnet"]
  region      = local.ctxtvars["region"]
  country     = local.ctxtvars["country"]
  environment = local.ctxtvars["environment"]

}