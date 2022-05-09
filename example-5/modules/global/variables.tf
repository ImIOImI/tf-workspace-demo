locals {
  vrctxt-list        = keys(local.contexts)
  vrctxt-list-string = jsonencode(local.vrctxt-list)
}

variable "context" {
  default     = "default"
  type        = string
  description = "Name of the workspace or context. "
  validation {
    condition     = contains(keys(local.contexts), var.context)
    error_message = format("Context must be one of the following: %s", local.vrctxt-list-string)
  }
}