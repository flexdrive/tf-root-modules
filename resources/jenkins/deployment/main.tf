
# ---------------------------------------------------------------------------------------------------------------------
# - deploy code
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "deploy-code" {
  deploy_target = "${module.blue_webserver.frontend_webserver_ip[0]}"
  code_version = "${var.code_version}"
  # depends_on = [
  #   "module.cfg_cd",
  # ]
    provisioner "local-exec" {
    command = "curl -X POST https://hsoneji:${var.api_token}@builds.garage.corp.flexdriveplatforms.com/job/${var.job_name}/buildWithParameters?VERSION=${var.code_version}&HOSTNAME=${var.deploy_target}"
  }  
}

variable "api_token" {
  default = "12312313131"
}
variable "job_name" {
  default = "terraform-test-repo"
}
