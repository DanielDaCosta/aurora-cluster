resource "aws_security_group" "this" {
  name   = "${var.app_name}-rds-endpoint-sg"
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Product = var.app_name
  }
}

resource "aws_security_group_rule" "ingress" {
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "TCP"
  type              = "ingress"
  cidr_blocks       = data.aws_subnet.private.*.cidr_block
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = data.aws_subnet.private.*.cidr_block
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "bastion" {
  count                    = var.bastion_access ? 1 : 0
  description              = "bastion-postgres-access"
  from_port                = var.db_port
  to_port                  = var.db_port
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = aws_security_group.this.id
}
