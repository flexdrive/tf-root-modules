data "aws_ssm_parameter" "mongodbatlas_public_key" {
  name = "/mongodbatlas/public_key"
}

data "aws_ssm_parameter" "mongodbatlas_private_key" {
  name = "/mongodbatlas/private_key"
}

data "aws_ssm_parameter" "mongodbatlas_org_id" {
  name = "/mongodbatlas/org_id"
}

provider "mongodbatlas" {
  public_key  = "${data.aws_ssm_parameter.mongodbatlas_public_key.value}"
  private_key = "${data.aws_ssm_parameter.mongodbatlas_private_key.value}"
}

variable "mongodbatlas_project_name" {
  type        = "string"
  description = "Name of the Mongo Atlas Project"
}

resource "mongodbatlas_project" "my_project" {
  name   = "${var.mongodbatlas_project_name}"
  org_id = "${data.aws_ssm_parameter.mongodbatlas_org_id.value}"
}
