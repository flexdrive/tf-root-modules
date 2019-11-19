variable "aws_assume_role_arn" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "attributes" {
  type = list(string)
  default = []
  description = "Additional attributes'
}

variable "force_destroy" {
  type = bool
  default = false
  description = "Destroy the user even if it has non-terraform managed IAM access keys"
}

variable "policy" {
  type = string
  default = ""
  description = "A valid IAM policy document.
}

variable "chamber_service" {
  type        = string
  default     = "circleci"
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

