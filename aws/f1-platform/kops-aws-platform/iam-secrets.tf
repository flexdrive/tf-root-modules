data "aws_iam_policy_document" "secrets" {
  statement {
    sid       = "kiamserveraa"
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
module "kiamserver_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"
  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "external-secrets-controller22"
  attributes         = ["kiamserver", "role"]
  role_description   = "Role for KIAM secrets"
  policy_description = "Allow read, decryption, and write to aws secrets manager"
  principals = {
    AWS = ["${module.kops_metadata_iam.masters_role_arn}"]
  }
  policy_documents = ["${data.aws_iam_policy_document.secrets.json}"]
}
