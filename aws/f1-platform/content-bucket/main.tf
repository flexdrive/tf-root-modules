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
  chamber_service = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
}

module "s3_bucket" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.3.1"
  namespace              = "${var.namespace}"
  stage                  = "${var.stage}"
  name                   = "${var.name}"
  attributes             = "${var.attributes}"
  allowed_bucket_actions = "${var.allowed_bucket_actions}"
  policy                 = "${var.policy}"
  versioning_enabled     = "${var.versioning_enabled}"
  user_enabled           = "${var.user_enabled}"
}

resource "aws_ssm_parameter" "bucket_user_name" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "bucket_user_name")}"
  value       = "${module.s3_bucket.user_name}"
  description = "Bucket user name"
  type        = "SecureString"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "bucket_user_arn" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "bucket_user_arn")}"
  value       = "${module.s3_bucket.user_arn}"
  description = "Bucket user arn"
  type        = "SecureString"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "bucket_user_access_key_id" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "bucket_user_access_key_id")}"
  value       = "${module.s3_bucket.access_key_id}"
  description = "Bucket user access key"
  type        = "SecureString"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "bucket_user_secret_access_key" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "bucket_user_secret_access_key")}"
  value       = "${module.s3_bucket.secret_access_key}"
  description = "Bucket user secret"
  type        = "SecureString"
  overwrite   = "true"
}
