resource "aws_db_subnet_group" "this" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = tolist(data.aws_subnet_ids.private.ids)
  tags = {
    Name = "${var.app_name}-aurora-db-subnet-group"
  }
}

resource "random_password" "db_master_pass" {
  length  = 64
  special = false
}

resource "aws_ssm_parameter" "db_master_pass" {
  name   = "/${var.app_name}/general/DB_MASTER_PASS"
  type   = "SecureString"
  key_id = aws_kms_key.this.id
  value  = random_password.db_master_pass.result
  tags = {
    Product = var.app_name
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier        = "${var.app_name}-aurora-cluster"
  availability_zones        = var.availability_zones
  backup_retention_period   = var.backup_retention_period
  copy_tags_to_snapshot     = true
  database_name             = replace(var.app_name, "-", "_")
  db_subnet_group_name      = aws_db_subnet_group.this.name
  deletion_protection       = true
  engine                    = var.engine_type
  engine_mode               = var.engine_mode
  enable_http_endpoint      = false
  final_snapshot_identifier = "${var.app_name}-aurora-cluster-final-snapshot"
  master_username           = var.master_db_user
  master_password           = random_password.db_master_pass.result
  vpc_security_group_ids    = [aws_security_group.this.id]
  storage_encrypted         = var.encrypted
  kms_key_id                = module.kms_key.arn

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  tags = {
    Product = var.app_name
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.instances_amount
  identifier         = "${aws_rds_cluster.default.cluster_identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version

  tags = {
    Product = var.app_name
  }
}

resource "aws_ssm_parameter" "db_writer_node" {
  name  = "/${var.app_name}/general/DB_WRITER_NODE"
  type  = "String"
  value = aws_rds_cluster.default.endpoint
  tags = {
    Product = var.app_name
  }
}
