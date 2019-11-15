output "bucket_domain_name" {
  value       = "${module.s3_bucket.bucket_domain_name}"
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = "${module.s3_bucket.bucket_id}"
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = "${module.s3_bucket.bucket_arn}"
  description = "Bucket ARN"
}

output "user_enabled" {
  value       = "${module.s3_bucket.user_enabled}"
  description = "Is user creation enabled"
}

output "user_name" {
  value       = "${module.s3_bucket.user_name}"
  description = "Normalized IAM user name"
}
