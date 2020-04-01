variable "aws_account_id" {
  type        = "string"
  description = "Names of zones for external-dns to manage (e.g. `us-east-1.cloudposse.com` or `cluster-1.cloudposse.com`)"
}

module "external_secrets_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "external-secrets"
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
}

resource "aws_iam_role" "external_secrets_role" {
  name        = "${module.external_secrets_label.id}"
  description = "Role that can be assumed by external-secrets"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = "${data.aws_iam_policy_document.external_secrets_assume_role_policy.json}"
}

data "aws_iam_policy_document" "external_secrets_assume_role_policy" {
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

resource "aws_iam_role_policy_attachment" "external_secrets_attachment" {
  role       = "${aws_iam_role.external_secrets_role.name}"
  policy_arn = "${aws_iam_policy.external_secrets_policy.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "${module.external_secrets_label.id}"
  description = "Grant permissions for external-secrets"
  policy      = "${data.aws_iam_policy_document.external_secrets_policy_document.json}"
}

data "aws_iam_policy_document" "external_secrets_policy_document" {
  statement {
    actions   = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
        "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:*",
        "arn:aws:kms:${var.region}:${var.aws_account_id}:key/*"
    ]
  }
}