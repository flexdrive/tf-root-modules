data "aws_ssm_parameter" "mongodbatlas_public_key" {
  name = "/mongodbatlas/public_key"
}

data "aws_ssm_parameter" "mongodbatlas_private_key" {
  name = "/mongodbatlas/private_key"
}

data "aws_ssm_parameter" "mongodbatlas_org_id" {
  name = "/mongodbatlas/org_id"
}

data "aws_ssm_parameter" "kops_network_cidr" {
  name = "/kops/${var.stage}/${var.cluster_name_prefix}/kops_network_cidr"
}

provider "mongodbatlas" {
  public_key  = "${data.aws_ssm_parameter.mongodbatlas_public_key.value}"
  private_key = "${data.aws_ssm_parameter.mongodbatlas_private_key.value}"
}

variable "atlas_project_name" {
  type        = "string"
  description = "Name of the Mongo Atlas Project"
}

variable "atlas_cidr_block" {
  type = "string"
  default = ""
  description = "The CIDR block for the Atlas network"
}

variable "aws_account_id" {
  type = "string"
}
variable "atlas_disk_size_gb" {
  type = "string"
  default = "10"
}
variable "atlas_provider_disk_iops" {
  type = "string"
  default = "100"
}
variable "atlas_provider_volume_type" {
  type = "string"
  default = "STANDARD"
}
variable "atlas_provider_encrypt_ebs_volume" {
  type = "string"
  default = "true"
}
variable "atlas_instance_size" {
  type = "string"
  default = "M10"
}

locals {
  atlas_cluster_name = "${var.stage}-${var.atlas_project_name}"
  atlas_project_name = "${var.namespace}-${var.stage}-${var.atlas_project_name}"
}

resource "mongodbatlas_project" "f1_project" {
  name   = "${local.atlas_project_name}"
  org_id = "${data.aws_ssm_parameter.mongodbatlas_org_id.value}"
}

resource "mongodbatlas_network_container" "f1_network" {
  project_id = "${mongodbatlas_project.f1_project.id}"
  atlas_cidr_block = "${var.atlas_cidr_block}"
  provider_name = "AWS"
  region_name = "${var.region}"
}

resource "mongodbatlas_network_peering" "peering" {
  accepter_region_name    = "${var.region}"   
  project_id              = "${mongodbatlas_project.f1_project.id}"
  container_id            = "${mongodbatlas_network_container.f1_network.container_id}"
  provider_name           = "AWS"
  route_table_cidr_block  = "${data.aws_ssm_parameter.kops_network_cidr.value}"
  vpc_id                  = "${module.kops_metadata.vpc_id}"
  aws_account_id          = "${var.aws_account_id}"
}

resource "mongodbatlas_cluster" "f1_atlas_cluster" {
  project_id   = "${mongodbatlas_project.f1_project.id}"
  name         = "${local.atlas_cluster_name}"
  num_shards   = 1

  replication_factor           = 3
  backup_enabled               = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.0"

  //Provider Settings "block"
  provider_name               = "AWS"
  disk_size_gb                = "${var.atlas_disk_size_gb}"
  provider_disk_iops          = "${var.atlas_provider_disk_iops}"
  provider_volume_type        = "${var.atlas_provider_volume_type}"
  provider_encrypt_ebs_volume = "${var.atlas_provider_encrypt_ebs_volume}"
  provider_instance_size_name = "${var.atlas_instance_size}"
  provider_region_name        = "${var.region}"
}