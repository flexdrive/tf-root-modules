terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

locals {
  chamber_service             = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
}

module "kops_state_backend" {
  source           = "git::https://github.com/cloudposse/terraform-aws-kops-state-backend.git?ref=tags/0.3.0"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.name}"
  attributes       = ["${var.kops_attribute}"]
  cluster_name     = "${coalesce(var.cluster_name_prefix, var.resource_region, var.region)}"
  parent_zone_name = "${var.zone_name}"
  zone_name        = "${var.complete_zone_name}"
  domain_enabled   = "${var.domain_enabled}"
  force_destroy    = "${var.force_destroy}"
  region           = "${coalesce(var.state_store_region, var.region)}"
  create_bucket    = "${var.create_state_store_bucket}"
}

resource "aws_ssm_parameter" "kops_state_store" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_state_store")}"
  value       = "s3://${module.kops_state_backend.bucket_name}"
  description = "Kops state store S3 bucket name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_state_store_region" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_state_store_region")}"
  value       = "${module.kops_state_backend.bucket_region}"
  description = "Kops state store (S3 bucket) region"
  type        = "String"
  overwrite   = "true"
}

