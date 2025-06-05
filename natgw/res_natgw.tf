## NAT Gateway
resource "aws_eip" "this" {
  for_each = local.availability_zones

  domain = "vpc"
  tags = {
    Name = "${local.prefix}-eip-nat-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = local.availability_zones

  allocation_id = aws_eip.this[each.key].allocation_id
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnets[each.value].id

  tags = {
    Name = "${local.prefix}-natgw-${each.key}"
  }
}

## Route to NAT Gateway for Private Subnets
resource "aws_route" "private_natgw" {
  for_each = local.availability_zones

  route_table_id         = data.terraform_remote_state.vpc.outputs.private_route_table_ids[each.value]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}
