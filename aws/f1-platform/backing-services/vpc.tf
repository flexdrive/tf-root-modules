locals {
  name = "backing-services"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_nat_gateway_enabled" {
  default = "true"
}

variable "vpc_max_subnet_count" {
  default     = 0
  description = "The maximum count of subnets to provision. 0 will provision a subnet for each availability zone within the region"
}

variable "kops_vpc_peer_auto_accept" {
  default = "false"
}

data "aws_region" "current" {}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.2"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  attributes = "${var.attributes}"
  name       = "${local.name}"
  cidr_block = "${var.vpc_cidr_block}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.8.0"
  availability_zones  = ["${local.availability_zones}"]
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  attributes          = "${var.attributes}"
  name                = "${local.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "${var.vpc_nat_gateway_enabled}"
  max_subnet_count    = "${var.vpc_max_subnet_count}"
}

module "vpc_peering_kops" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=0.11/master"
  stage      = "${var.stage}"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  attributes = "${compact(concat(var.attributes, list("peering")))}"

  requestor_vpc_id   = "${module.kops_metadata.vpc_id}"
  acceptor_vpc_id    = "${module.vpc.vpc_id}"
  auto_accept        = "${var.kops_vpc_peer_auto_accept}"
}

resource "aws_route" "backing_services_kops_route" {
  count = "${length(data.aws_route_tables.cluster_private_routes.ids)}"
  route_table_id = "${data.aws_route_tables.cluster_private_routes.ids[count.index]}"
  destination_cidr_block = "${var.vpc_cidr_block}"
  vpc_peering_connection_id = "${module.vpc_peering_kops.connection_id}"
}

output "vpc_id" {
  description = "VPC ID of backing services"
  value       = "${module.vpc.vpc_id}"
}

output "public_subnet_ids" {
  description = "Public subnet IDs of backing services"
  value       = ["${module.subnets.public_subnet_ids}"]
}

output "private_subnet_ids" {
  description = "Private subnet IDs of backing services"
  value       = ["${module.subnets.private_subnet_ids}"]
}

output "region" {
  description = "AWS region of backing services"
  value       = "${data.aws_region.current.name}"
}
