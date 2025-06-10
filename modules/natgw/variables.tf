variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "public_subnets" {
  description = "Map of availability zones to public subnet CIDR blocks"
  type = map(object({
    id = string
  }))
}

variable "private_route_table_ids" {
  description = "Map of availability zones to private route table IDs"
  type        = map(string)
}

variable "azs_to_allocate" {
  description = "List of availability zones to allocate resources in (eg. [\"a\", \"c\", \"d\"])"
  type        = list(string)
}

