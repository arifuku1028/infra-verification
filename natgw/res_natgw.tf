## NAT Gateway
resource "aws_eip" "this" {
  for_each = toset(local.azs_to_allocate)

  domain = "vpc"
  tags = {
    Name = "${local.prefix}-eip-nat-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.azs_to_allocate)

  allocation_id = aws_eip.this[each.key].allocation_id
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnets["${local.region}${each.key}"].id

  tags = {
    Name = "${local.prefix}-natgw-${each.key}"
  }
}

## Route to NAT Gateway for Private Subnets
resource "aws_route" "private_natgw" {
  for_each = toset(local.azs_to_allocate)

  route_table_id         = data.terraform_remote_state.vpc.outputs.private_route_table_ids["${local.region}${each.key}"]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}
