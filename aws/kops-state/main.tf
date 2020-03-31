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
  source           = "git::https://github.com/flexdrive/terraform-aws-kops-state-bucket.git?ref=tags/0.1.0"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.name}"
  attributes       = ["${var.kops_attribute}"]
  force_destroy    = "${var.force_destroy}"
  region           = "${coalesce(var.state_store_region, var.region)}"
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

