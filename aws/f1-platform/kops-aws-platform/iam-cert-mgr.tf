# v2
# data "aws_route53_zone" "prod-dns" {
#   name         = "${var.env_domain}."
# }
# data "aws_route53_zone" "staging-dns" {
#   name         = "staging.${var.env_domain}."
# }
# variable env_domain {
#     type = string
#     default = "f1.super-rentals.carmax.net"
#     description = "What is the domain of the platform? (The domain you see when using the environment) For example, f1.shft.no"
# }

data "aws_iam_policy_document" "certmgr" {
  statement {
    # sid       = "ext-secrets"
    actions   = [ "route53:GetChange" ]
    resources = [ "arn:aws:route53:::change/*" ]
  }
 statement {
    # sid       = "ext-secrets"
    actions   = [ "route53:ChangeResourceRecordSets" ]
    resources = [ "arn:aws:route53:::hostedzone/${element(var.env_dnszone_ids,0)}", "arn:aws:route53:::hostedzone/${element(var.env_dnszone_ids,1)}" ]
    # v2
    # "arn:aws:route53:::hostedzone/${data.aws_route53_zone.prod-dns.zone_id}", "arn:aws:route53:::hostedzone/${data.aws_route53_zone.staging-dns.zone_id}"
  }
 statement {
    # sid       = "ext-secrets"
    actions   = [ "route53:ListHostedZonesByName" ]
    resources = [ "*" ]
  }
}
module "cert-manager-role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"
  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "cert-manager"
  role_description   = "Role for Certs Manager"
  policy_description = "Needs ability to perform DNS validation to manage SSL/TLS certificates"
  principals = {
    AWS = ["${module.kiam_server_role.aws_iam_role.default.arn}"]
  }
  policy_documents = ["${data.aws_iam_policy_document.certmgr.json}"]
}
output "cert-manager-role_name" {
  value       = "${module.cert-manager-role.name}"
  description = "The name of the IAM role created"
}

output "cert-manager-role_id" {
  value       = "${module.cert-manager-role.id}"
  description = "The stable and unique string identifying the role"
}

output "cert-manager-role_arn" {
  value       = "${module.cert-manager-role.arn}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}
