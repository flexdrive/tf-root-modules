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
    # two hosted zones
    # domain.com and qa.domain.com
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
  name               = "cert-manager2"
  role_description   = "Role for Certs Manager"
  policy_description = "Needs ability to perform DNS validation to manage SSL/TLS certificates"
  principals = {
    AWS = ["${module.kops_metadata_iam.masters_role_arn}"]
  }
  policy_documents = ["${data.aws_iam_policy_document.certmgr.json}"]
}
