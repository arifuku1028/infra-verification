output "vpc" {
  value = {
    id   = aws_vpc.this.id
    cidr = aws_vpc.this.cidr_block
  }
}

output "public_subnets" {
  value = {
    for subnet in aws_subnet.public :
    subnet.availability_zone => {
      id   = subnet.id
      cidr = subnet.cidr_block
    }
  }
}

output "private_subnets" {
  value = {
    for subnet in aws_subnet.private :
    subnet.availability_zone => {
      id   = subnet.id
      cidr = subnet.cidr_block
    }
  }
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}


output "private_route_table_ids" {
  value = {
    for key, subnet in aws_subnet.private :
    subnet.availability_zone => aws_route_table.private[key].id
  }
}
