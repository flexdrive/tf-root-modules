terraform {
  backend "s3" {}
}

locals {
  chamber_service = var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service
  chamber_parameter_format = "/%s/%s"
}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "circleci_user" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=tags/0.6.0"
  namespace = var.namespace
  stage = var.stage
  attributes = var.attributes
  name = var.name
  force_destroy = var.force_destroy
}

resource "aws_iam_user_policy" "circleci_user" {
  name = module.circleci_user.username
  user = module.circleci_user.username
  policy = var.policy
}

resource "aws_ssm_parameter" "circleci_user_arn" {
  name        = format(local.chamber_parameter_format, local.chamber_service, "circleci_user_arn")
  value       = module.circleci_user.user_arn
  description = "CircleCI user arn"
  type        = "SecureString"
  overwrite   = true
}

resource "aws_ssm_parameter" "circleci_user_access_key_id" {
  name        = format(local.chamber_parameter_format, local.chamber_service, "circleci_user_access_key_id")
  value       = module.circleci_user.access_key_id
  description = "CircleCI user accessKeyId"
  type        = "SecureString"
  overwrite   = true
}

resource "aws_ssm_parameter" "circleci_user_secret_access_key" {
  name        = format(local.chamber_parameter_format, local.chamber_service, "circleci_user_secret_access_key")
  value       = module.circleci_user.secret_access_key
  description = "CircleCI user secretAccessKey"
  type        = "SecureString"
  overwrite   = true
}
