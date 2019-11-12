output "cert_time" {
  value = "${data.external.letsencrypt_docker.result.timestamp}"
}

output "cert_name" {
  value = "${data.external.letsencrypt_docker.result.cert_name}"
}

output "cert_body" {
  value = "${data.external.letsencrypt_docker.result.cert_contents}"
}

output "cert_key" {
  value = "${data.external.letsencrypt_docker.result.cert_key}"
}

variable "cert_name" {
  description = "Arbitrary name of certificate (and group of hosts it contains)."
}

variable "san_names" {
  description = "Members of the Subject Alternative Name certificate"
  type = "list"
}

data "external" "letsencrypt_docker" {
  program = ["bash", "${path.module}/generate.sh"]

  query = {
    cert_name = "${var.cert_name}"
    san_names = "${join(",", var.san_names)}"
  }
}

