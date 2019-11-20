
data "aws_iam_policy_document" "kiam_server" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

module "kiam_server_role" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.4.0"

  enabled            = "true"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "kiam-server"
  role_description   = "Role for Kiam Server"
  policy_description = "Permit kiam-server to assume other roles"

  principals = {
    AWS = ["${module.kops_metadata_iam.masters_role_arn}"]
  }

  policy_documents = ["${data.aws_iam_policy_document.kiam_server.json}"]
}
