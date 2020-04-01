module "cert_manager_dns_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "cert-manager"
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
}

resource "aws_iam_role" "cert_manager_role" {
  name        = "${module.cert_manager_dns_label.id}"
  description = "Role that can be assumed by cert-manager"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = "${data.aws_iam_policy_document.cert_manager_assume_role_policy.json}"
}

data "aws_iam_policy_document" "cert_manager_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = ["${module.kiam_server_role.arn}"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "cert_manager_attachment" {
  role       = "${aws_iam_role.cert_manager_role.name}"
  policy_arn = "${aws_iam_policy.cert_manager_policy.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "${module.cert_manager_dns_label.id}"
  description = "Grant permissions for cert-manager"
  policy      = "${data.aws_iam_policy_document.certmgr.json}"
}

data "aws_route53_zone" "cert_manager_zones" {
  count        = "${length(var.certmanager_dns_zone_names)}"
  name         = "${element(var.certmanager_dns_zone_names, count.index)}."
  private_zone = false
}

data "aws_iam_policy_document" "certmgr" {
  statement {
    actions   = [ "route53:GetChange" ]
    resources = [ "arn:aws:route53:::change/*" ]
  }
 statement {
    actions   = [ "route53:ChangeResourceRecordSets" ]
    resources = [ "${formatlist("arn:aws:route53:::hostedzone/%s", data.aws_route53_zone.cert_manager_zones.*.zone_id)}" ]
  }
 statement {
    actions   = [ "route53:ListHostedZonesByName" ]
    resources = [ "*" ]
  }
}

# module "cert-manager-role" {
#   source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"
#   enabled            = "true"
#   namespace          = "${var.namespace}"
#   stage              = "${var.stage}"
#   name               = "cert-manager"
#   role_description   = "Role for Certs Manager"
#   policy_description = "Needs ability to perform DNS validation to manage SSL/TLS certificates"
#   principals = {
#     AWS = ["${module.kiam_server_role.arn}"]
#   }
#   policy_documents = ["${data.aws_iam_policy_document.certmgr.json}"]
# }

# output "cert-manager-role_name" {
#   value       = "${module.cert-manager-role.name}"
#   description = "The name of the IAM role created"
# }

# output "cert-manager-role_id" {
#   value       = "${module.cert-manager-role.id}"
#   description = "The stable and unique string identifying the role"
# }

# output "cert-manager-role_arn" {
#   value       = "${module.cert-manager-role.arn}"
#   description = "The Amazon Resource Name (ARN) specifying the role"
# }