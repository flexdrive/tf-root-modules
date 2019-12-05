terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "attributes" {
  type        = "list"
  description = "Additional list of attibutes to use in the labeling"
  default     = []
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "vpc_peering_enabled" {
  type = "string"
  default = "false"
}

variable "cluster_name_prefix" {
  default = ""
}

locals {
  name = "backing-services"
}

data "aws_vpc" "backing_services_vpc" {
  filter {
    name = "tag:Name"
    values = ["${format("%s-%s-%s-%s", var.namespace, var.stage, local.name, join(", ", var.attributes))}"]
  }
}

data "aws_ssm_parameter" "kops_network_cidr" {
  name = "/kops/${var.stage}/${var.cluster_name_prefix}/kops_network_cidr"
}

data "aws_vpc" "kops_vpc" {
  cidr_block = "${data.aws_ssm_parameter.kops_network_cidr.value}"
}

module "vpc_peering" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=0.11/master"
  enabled          = "${var.vpc_peering_enabled}"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${local.name}"
  attributes       = ["${compact(concat(var.attributes, list("peering")))}"]
  requestor_vpc_id = "${data.aws_vpc.backing_services_vpc.id}"
  acceptor_vpc_id  = "${data.aws_vpc.kops_vpc.id}"
}
