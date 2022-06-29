locals {
    contexts = {
    default = {
      environment = "dev"
      region      = "east"
      country     = "us"
      subnet      = cidrsubnet(local.network, 16, 0)
    }
    dev = {
      subnet = cidrsubnet(local.network, 16, 1)
    }
    infra = {
      subnet = cidrsubnet(local.network, 16, 2)
    }
    stage-east = {
      environment = "stage"
      subnet      = cidrsubnet(local.network, 16, 3)
    }
    stage-west = {
      environment = "stage"
      region      = "west"
      subnet      = cidrsubnet(local.network, 16, 4)
    }
    prod-east = {
      environment = "prod"
      subnet      = cidrsubnet(local.network, 16, 5)
    }
    prod-west = {
      environment = "prod"
      region      = "west"
      subnet      = cidrsubnet(local.network, 16, 6)
    }
  }
}