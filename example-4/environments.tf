locals {
  environments = {
    dev = {
      k8s-max-nodes = 10
      environment-long = "development"
      environment-short = "dev"
    }
    stage = {
      k8s-max-nodes = 30
      environment-long = "staging"
      environment-short = "stg"
    }
    prod = {
      k8s-max-nodes = 30
      environment-long = "production"
      environment-short = "prd"
    }
  }
}