resource "aws_security_group" "main" {
  name   = "${var.name}-${var.unique_id}"
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = toset(var.ingress_rules)
    content {
      cidr_blocks      = ingress.value.cidr_blocks
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      prefix_list_ids  = ingress.value.prefix_list_ids
      protocol         = ingress.value.protocol
      security_groups  = ingress.value.security_groups
      to_port          = ingress.value.to_port
      self             = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = toset(var.egress_rules)
    content {
      cidr_blocks      = egress.value.cidr_blocks
      description      = egress.value.description
      from_port        = egress.value.from_port
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      prefix_list_ids  = egress.value.prefix_list_ids
      protocol         = egress.value.protocol
      security_groups  = egress.value.security_groups
      to_port          = egress.value.to_port
      self             = egress.value.self
    }
  }

  tags = merge({ Name = "${var.name}-${var.unique_id}" }, var.tags)
}
