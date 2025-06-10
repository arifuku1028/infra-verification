variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with availability zone as key (eg. { \"a\" = \"172.18.0.0/26\" })"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of private subnets with availability zone as key (eg. { \"a\" = \"172.18.12.0/26\" })"
  type        = map(string)
}
