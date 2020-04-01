module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.1.1"
  cluster_name = "${coalesce(var.cluster_name_prefix, var.region)}.${var.zone_name}"
}

module "kops_metadata_iam" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.1.0"
  cluster_name = "${coalesce(var.cluster_name_prefix, var.region)}.${var.zone_name}"
}
