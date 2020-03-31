output "bucket_name" {
  value = "${module.kops_state_backend.bucket_name}"
}

output "bucket_region" {
  value = "${module.kops_state_backend.bucket_region}"
}

output "bucket_domain_name" {
  value = "${module.kops_state_backend.bucket_domain_name}"
}

output "bucket_id" {
  value = "${module.kops_state_backend.bucket_id}"
}

output "bucket_arn" {
  value = "${module.kops_state_backend.bucket_arn}"
}
