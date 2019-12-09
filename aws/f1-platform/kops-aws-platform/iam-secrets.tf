data "aws_iam_policy_document" "secrets" {
  statement {
    actions   = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
        "arn:aws:secretsmanager:${var.region}:${element(split(":", var.aws_assume_role_arn), 4)}:secret:*",
        "arn:aws:kms:${var.region}:${element(split(":", var.aws_assume_role_arn), 4)}:key/*"
    ]
  }
}
module "external-secrets-role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"
  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "external-secrets-controller-TEST" # Will remove TEST from name when we merge
  role_description   = "Role for External Secrets Manager"
  policy_description = "Allow read, decryption, and write to aws secrets manager"
  principals = {
    AWS = ["${module.kops_metadata_iam.masters_role_arn}"]
  }
  policy_documents = ["${data.aws_iam_policy_document.secrets.json}"]
}

output "external-secrets-role_name" {
  value       = "${module.external-secrets-role.name}"
  description = "The name of the IAM role created"
}

output "external-secrets-role_id" {
  value       = "${module.external-secrets-role.id}"
  description = "The stable and unique string identifying the role"
}

output "external-secrets-role_arn" {
  value       = "${module.external-secrets-role.arn}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}