variable "external_dns_zone_names" {
  type        = "list"
  description = "Names of zones for external-dns to manage (e.g. `us-east-1.cloudposse.com` or `cluster-1.cloudposse.com`)"
}

module "external_dns_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "external-dns"
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
}

resource "aws_iam_role" "external_dns_role" {
  name        = "${module.external_dns_label.id}"
  description = "Role that can be assumed by external-dns"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = "${data.aws_iam_policy_document.external_dns_assume_role_policy.json}"
}

data "aws_iam_policy_document" "external_dns_assume_role_policy" {
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

resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  role       = "${aws_iam_role.external_dns_role.name}"
  policy_arn = "${aws_iam_policy.external_dns_policy.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "${module.external_dns_label.id}"
  description = "Grant permissions for external-dns"
  policy      = "${data.aws_iam_policy_document.external_dns_policy_document.json}"
}

data "aws_route53_zone" "default" {
  count        = "${length(var.external_dns_zone_names)}"
  name         = "${element(var.external_dns_zone_names, count.index)}."
  private_zone = false
}

data "aws_iam_policy_document" "external_dns_policy_document" {
  statement {
    sid = "GrantModifyAccessToDomains"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    effect = "Allow"

    resources = [
      "${formatlist("arn:aws:route53:::hostedzone/%s", data.aws_route53_zone.default.*.zone_id)}",
    ]
  }

  statement {
    sid = "GrantListAccessToDomains"

    # route53:ListHostedZonesByName is not needed by external-dns, but is needed by cert-manager
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  # route53:GetChange is not needed by external-dns, but is needed by cert-manager
  statement {
    sid = "GrantGetChangeStatus"

    actions = [
      "route53:GetChange",
    ]

    effect = "Allow"

    resources = ["arn:aws:route53:::change/*"]
  }
}

# output "kops_external_dns_role_name" {
#   value       = "${aws_iam_role.default.name}"
#   description = "IAM role name"
# }

# output "kops_external_dns_role_unique_id" {
#   value       = "${aws_iam_role.default.unique_id}"
#   description = "IAM role unique ID"
# }

# output "kops_external_dns_role_arn" {
#   value       = "${aws_iam_role.default.arn}"
#   description = "IAM role ARN"
# }

# output "kops_external_dns_policy_name" {
#   value       = "${aws_iam_policy.default.name}"
#   description = "IAM policy name"
# }

# output "kops_external_dns_policy_id" {
#   value       = "${aws_iam_policy.default.id}"
#   description = "IAM policy ID"
# }

# output "kops_external_dns_policy_arn" {
#   value       = "${aws_iam_policy.default.arn}"
#   description = "IAM policy ARN"
# }
