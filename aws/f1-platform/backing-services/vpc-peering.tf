module "vpc_peering" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=0.11/master"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${local.name}"
  attributes       = ["${compact(concat(var.attributes, list("peering")))}"]
  requestor_vpc_id = "${module.vpc.vpc_id}"
  acceptor_vpc_id  = "${module.kops_metadata.vpc_id}"
}
