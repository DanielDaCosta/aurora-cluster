variable "app_name" {
  description = "Product Name"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "engine_type" {
  # aurora | aurora-mysql | aurora-postgres
  description = "RDS Aurora serverless engine type"
  type        = string
}

variable "engine_version" {
  description = "RDS Aurora engine version"
  type        = string
}

variable "engine_mode" {
  # global, multimaster, parallelquery, provisioned, serverless
  description = "The database engine mode"
  type        = string
  default     = "provisioned"
}

variable "instance_class" {
  description = "RDS Aurora instance class"
  type        = string
  default     = null
}

variable "instances_amount" {
  description = "Amound of instances for aurora cluster"
  type        = number
  default     = 0
}

variable "master_db_user" {
  description = "Master db user name"
  type        = string
}

variable "encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  type        = bool
}

variable "bastion_access" {
  description = "Add Bastion securityGroup"
  type        = bool
  default     = false
}

variable "bastion_sg_id" {
  description = "Bastion securityGroup"
  type        = string
  default     = null
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when engine_mode is set to `serverless`"
  type        = map(string)
  default     = {}
}
