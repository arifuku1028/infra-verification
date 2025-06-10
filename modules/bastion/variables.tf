variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc" {
  description = "ID and CIDR block of the VPC where the bastion host will be created"
  type = object({
    id   = string
    cidr = string
  })
}

variable "subnets" {
  description = "Map of availability zones to subnet IDs"
  type = map(object({
    id = string
  }))
}

variable "az_to_allocate" {
  description = "Availability zone to allocate bastion host in (eg. \"a\")"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t4g.micro"
}

variable "architecture" {
  description = "Architecture for the bastion host (eg. \"arm64\" or \"x86_64\")"
  type        = string

  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "Architecture must be either 'arm64' or 'x86_64'."
  }
}

variable "use_spot_instances" {
  description = "Whether to use spot instances for the bastion host"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "Key pair name for SSH access to instance"
  type        = string
}
