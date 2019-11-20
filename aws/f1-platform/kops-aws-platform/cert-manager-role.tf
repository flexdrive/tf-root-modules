variable "cert_manager_zone_arns" {
  type        = "list"
  description = "List of zones that cert manager is managing"
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions = [
      "route53:GetChange",
    ]

    resources = [
      "arn:aws:route53:::change/*",
    ]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = "${var.cert_manager_zone_arns}"
  }
}

module "cert_manager_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"

  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "cert-manager"
  role_description   = "Role for JetStack CertManager"
  policy_description = "Permit cert-manager DNS validation against authorized hosted zones"

  principals = {
    AWS = ["${module.kiam_server_role.arn}"]
  }

  policy_documents = ["${data.aws_iam_policy_document.cert_manager.json}"]
}

resource "aws_ssm_parameter" "cert_manager_iam_role_name" {
  name        = "${format(local.chamber_parameter_format, var.chamber_service, "cert_manager_iam_role_name")}"
  value       = "${module.cert_manager_role.name}"
  description = "IAM role name for cert-manager"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "cert_manager_iam_role_arn" {
  name        = "${format(local.chamber_parameter_format, var.chamber_service, "cert_manager_iam_role_arn")}"
  value       = "${module.cert_manager_role.arn}"
  description = "IAM role arn for cert-manager"
  type        = "String"
  overwrite   = "true"
}

output "cert_manager_role_name" {
  value       = "${module.cert_manager_role.name}"
  description = "The name of the IAM role created"
}

output "cert_manager_role_id" {
  value       = "${module.cert_manager_role.id}"
  description = "The stable and unique string identifying the role"
}

output "cert_manager_role_arn" {
  value       = "${module.cert_manager_role.arn}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}
