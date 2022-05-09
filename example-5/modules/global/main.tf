locals {
  //if the workspace is contained in the context map, use it, otherwise use the default context
  ctxtvar = contains(keys(local.contexts), local.workspace) ? local.workspace : "default"

  //merge all the defaults with their contexts
  merged-contexts = {
  for context, values in local.contexts : context =>
  merge(
    local.contexts["default"],
    values,
  )
  }

  //lace it all together by adding in the defined variables in environments and regions
  all-contexts = {
  for context, values in local.merged-contexts : context =>
  merge(
    values,
    local.environments[values.environment],
    local.regions[values.region],
  )
  }

  subnet        = local.all-contexts[local.ctxtvar]["subnet"]
  region        = local.all-contexts[local.ctxtvar]["region"]
  country       = local.all-contexts[local.ctxtvar]["country"]
  environment   = local.all-contexts[local.ctxtvar]["environment"]
  timezone      = local.all-contexts[local.ctxtvar]["timezone"]
  time-offset   = local.all-contexts[local.ctxtvar]["time-offset"]
  k8s-max-nodes = local.all-contexts[local.ctxtvar]["k8s-max-nodes"]
  hub-subnet    = local.all-contexts["infra"]["subnet"]
}