## Public Subnet
resource "aws_subnet" "public" {
  for_each = local.availability_zones

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, each.value.index)
  availability_zone = each.value.name
  tags = {
    Name = "${local.prefix}-subnet-pub-${each.key}"
  }
}


## Private Subnet
resource "aws_subnet" "private" {
  for_each = local.availability_zones

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, each.value.index + 10)
  availability_zone = each.value.name
  tags = {
    Name = "${local.prefix}-subnet-pri-${each.key}"
  }
}


## Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-rtb-pub"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}


## Route Table for Private Subnets
resource "aws_route_table" "private" {
  for_each = local.availability_zones

  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-rtb-pri-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
