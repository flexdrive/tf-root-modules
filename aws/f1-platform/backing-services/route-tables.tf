data "aws_route_tables" "cluster_private_routes" {
  vpc_id = "${module.kops_metadata.vpc_id}"

  filter {
    name   = "tag:kubernetes.io/kops/role"
    values = ["private*"]
  }
}

data "aws_route_tables" "backing_services_private_routes" {
  vpc_id = "${module.vpc.vpc_id}"

  filter {
    name = "tag:cpco.io/subnet/type"
    values = ["private"]
  }
}

resource "aws_route" "cluster_atlas_route" {
  count = "${length(data.aws_route_tables.cluster_private_routes.ids)}"
  route_table_id = "${data.aws_route_tables.cluster_private_routes.ids[count.index]}"
  destination_cidr_block = "${mongodbatlas_network_container.f1_network.atlas_cidr_block}"
  vpc_peering_connection_id = "${mongodbatlas_network_peering.peering.connection_id}"
}

resource "aws_route" "cluster_backing_services_route" {
  count = "${length(data.aws_route_tables.cluster_private_routes.ids)}"
  route_table_id = "${data.aws_route_tables.cluster_private_routes.ids[count.index]}"
  destination_cidr_block = "${module.vpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${module.vpc_peering.connection_id}"
}

resource "aws_route" "backing_services_cluster_route" {  
  count = "${length(data.aws_route_tables.backing_services_private_routes.ids)}"
  route_table_id = "${data.aws_route_tables.backing_services_private_routes.ids[count.index]}"
  destination_cidr_block = "${data.aws_ssm_parameter.kops_network_cidr.value}"
  vpc_peering_connection_id = "${module.vpc_peering.connection_id}"
}