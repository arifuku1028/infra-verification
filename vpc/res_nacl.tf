## Network ACL
resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-nacl"
  }
}

resource "aws_network_acl_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  network_acl_id = aws_network_acl.this.id
}

resource "aws_network_acl_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  network_acl_id = aws_network_acl.this.id
}

resource "aws_network_acl_rule" "egress_allow_all" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 100
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  protocol       = "all"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "ingress_allow_all" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 100
  egress         = false
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  protocol       = "all"
  from_port      = 0
  to_port        = 0
}
