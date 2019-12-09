data "aws_iam_policy_document" "secrets" {
  statement {
    sid       = "ext-secrets"
    actions   = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
        "arn:aws:secretsmanager:${var.region}:${element(split(":", var.aws_assume_role_arn), 5)}:secret:*",
        "arn:aws:kms:${var.region}:${element(split(":", var.aws_assume_role_arn), 5)}:key/*"
    ]
  }
}
module "external-secrets-role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"
  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "external-secrets-controller"
  role_description   = "Role for External Secrets Manager"
  policy_description = "Allow read, decryption, and write to aws secrets manager"
  principals = {
    AWS = ["${module.kops_metadata_iam.masters_role_arn}"]
  }
  policy_documents = ["${data.aws_iam_policy_document.secrets.json}"]
}
