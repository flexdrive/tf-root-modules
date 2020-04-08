variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  default = "/%s/%s"
}

variable "cluster_name_prefix" {
  default = ""
}

variable "tenant_environment" {
  type = "string"
  default = ""
  description = "Environment (prod or staging) for the tenant"
}
