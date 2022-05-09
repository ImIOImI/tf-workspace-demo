locals {
  vrctxt-list        = keys(local.contexts)
  vrctxt-list-string = jsonencode(local.vrctxt-list)
}

variable "context" {
  default     = "default"
  type        = string
  description = "Name of the workspace or context."
}