output "vpc" {
  value = {
    id   = module.vpc.vpc.id
    cidr = module.vpc.vpc.cidr
  }
}

output "public_subnets" {
  value = {
    for az, subnet in module.vpc.public_subnets :
    az => {
      id   = subnet.id
      cidr = subnet.cidr
    }
  }
}

output "private_subnets" {
  value = {
    for az, subnet in module.vpc.private_subnets :
    az => {
      id   = subnet.id
      cidr = subnet.cidr
    }
  }
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}


output "private_route_table_ids" {
  value = {
    for az, route_table_id in module.vpc.private_route_table_ids :
    az => route_table_id
  }
}
