variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name  (e.g. `kops`)"
  default     = "kops"
}

variable "region" {
  type        = "string"
  default     = ""
  description = "AWS region for resources. Can be overriden by `resource_region` and `state_store_region`"
}

variable "state_store_region" {
  type        = "string"
  default     = ""
  description = "Region where to create the S3 bucket for the kops state store. Defaults to `var.region`"
}

variable "create_state_store_bucket" {
  type        = "string"
  default     = "true"
  description = "Set to `false` to use existing S3 bucket (e.g. from another region)"
}

variable "kops_attribute" {
  type        = "string"
  description = "Additional attribute to kops state bucket"
  default     = "state"
}

variable "cluster_name_prefix" {
  type        = "string"
  default     = ""
  description = "Prefix to add before parent DNS zone name to identify this cluster, e.g. `us-east-1`. Defaults to `var.resource_region`"
}

variable "force_destroy" {
  type        = "string"
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without errors. These objects are not recoverable."
  default     = "false"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  default = "/%s/%s"
}
