locals {
  workspace = var.context

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

  //now we can add values to the map that cut across domains like org/env/region
  all = {
    for context, v in local.all-contexts : context =>
      merge(
        v,
        {env-timezone = "${v.environment-short}-${v.country}-${v.timezone}"}
      )
  }

  environment   = local.all[local.ctxtvar]["environment"]
  env-timezone  = local.all[local.ctxtvar]["env-timezone"]
  country       = local.all[local.ctxtvar]["country"]
  k8s-max-nodes = local.all[local.ctxtvar]["k8s-max-nodes"]
  hub-subnet    = local.all["infra"]["subnet"]
  location      = local.all[local.ctxtvar]["location"]
  region        = local.all[local.ctxtvar]["region"]
  subnet        = local.all[local.ctxtvar]["subnet"]
  timezone      = local.all[local.ctxtvar]["timezone"]
  time-offset   = local.all[local.ctxtvar]["time-offset"]
}