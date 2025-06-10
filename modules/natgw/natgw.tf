## NAT Gateway
resource "aws_eip" "this" {
  for_each = toset(var.azs_to_allocate)

  domain = "vpc"
  tags = {
    Name = "${var.prefix}-eip-nat-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = toset(var.azs_to_allocate)

  allocation_id = aws_eip.this[each.key].allocation_id
  subnet_id     = var.public_subnets["${var.region}${each.key}"].id

  tags = {
    Name = "${var.prefix}-natgw-${each.key}"
  }
}

## Route to NAT Gateway for Private Subnets
resource "aws_route" "private_natgw" {
  for_each = toset(var.azs_to_allocate)

  route_table_id         = var.private_route_table_ids["${var.region}${each.key}"]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}
