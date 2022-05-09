locals {
  organisation-id = "06288276-e890-4c3d-bfe7-bdb96cfd304b"
  network      = "10.0.0.0/8"

  contexts = {
    default = {
      subnet = cidrsubnet(local.network, 16, 0)
    }
    dev = {
      subnet = cidrsubnet(local.network, 16, 1)
    }
    infra = {
      subnet = cidrsubnet(local.network, 16, 2)
    }
    stage = {
      subnet = cidrsubnet(local.network, 16, 3)
    }
    prod = {
      subnet = cidrsubnet(local.network, 16, 4)
    }
  }

  workspace = terraform.workspace
  subnet    = local.contexts[local.workspace]["subnet"]
}