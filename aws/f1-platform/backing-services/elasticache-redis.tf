variable "redis_name" {
  type        = "string"
  default     = "redis"
  description = "Redis name"
}

variable "redis_instance_type" {
  type        = "string"
  default     = "cache.t2.small"
  description = "EC2 instance type for Redis cluster"
}

variable "redis_cluster_size" {
  type        = "string"
  default     = "1"
  description = "Redis cluster size"
}

variable "redis_cluster_enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "redis_transit_encryption_enabled" {
  type        = "string"
  default     = "true"
  description = "Enable TLS"
}

variable "redis_at_rest_encryption_enabled" {
  type        = "string"
  default     = "true"
  description = "Enable at-rest encryption"
}

variable "redis_engine_version" {
  type        = "string"
  default     = "5.0.5"
  description = "Set the redis engine version"
}

variable "redis_engine_family" {
  type        = "string"
  default     = "redis5.0"
  description = "Set the redis engine family for the version being used"
}

variable "redis_params" {
  type        = "list"
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from a Redis family to another"
}

resource "random_string" "auth_token" {
  length  = 64
  special = false
}

locals {
  private_subnets = "${length(list)}"
}

module "elasticache_redis" {
  source                       = "git::https://github.com/flexdrive/terraform-aws-elasticache-redis.git?ref=0.11/master"
  namespace                    = "${var.namespace}"
  stage                        = "${var.stage}"
  attributes                   = "${var.attributes}"
  name                         = "${var.redis_name}"
  zone_id                      = "${local.zone_id}"
  security_groups              = ["${module.kops_metadata.nodes_security_group_id}"]
  vpc_id                       = "${module.vpc.vpc_id}"
  subnets                      = ["${module.subnets.private_subnet_ids}"]
  cluster_size                 = "${var.redis_cluster_size}"
  instance_type                = "${var.redis_instance_type}"
  transit_encryption_enabled   = "${var.redis_transit_encryption_enabled}"
  at_rest_encryption_enabled   = "${var.redis_at_rest_encryption_enabled}"
  engine_version               = "${var.redis_engine_version}"
  family                       = "${var.redis_engine_family}"
  port                         = "6379"
  alarm_cpu_threshold_percent  = "75"
  alarm_memory_threshold_bytes = "10000000"
  apply_immediately            = "true"
  availability_zones           = ["${local.availability_zones}"]
  automatic_failover           = "false"
  enabled                      = "${var.redis_cluster_enabled}"
  auth_token                   = "${random_string.auth_token.result}"

  parameter = "${var.redis_params}"
}

resource "aws_ssm_parameter" "redis_auth_token" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "redis_auth_token")}"
  value       = "${random_string.auth_token.result}"
  description = "Redis auth token"
  type        = "SecureString"
  overwrite   = "true"
}

output "elasticache_redis_id" {
  value = "${module.elasticache_redis.id}"
}

output "elasticache_redis_security_group_id" {
  value = "${module.elasticache_redis.security_group_id}"
}

output "elasticache_redis_host" {
  value = "${module.elasticache_redis.host}"
}
