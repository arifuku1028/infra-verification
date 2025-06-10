variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc" {
  description = "ID and CIDR block of the VPC where the Auto Scaling Group will be created"
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

variable "azs_to_allocate" {
  description = "List of availability zones to allocate Auto Scaling Group in (eg. [\"a\", \"c\", \"d\"])"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
}

variable "instance_type" {
  description = "Instance type for the Auto Scaling Group"
  type        = string
}

variable "architecture" {
  description = "Architecture for the Auto Scaling Group (eg. \"arm64\" or \"x86_64\")"
  type        = string

  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "Architecture must be either 'arm64' or 'x86_64'."
  }
}

variable "use_spot_instances" {
  description = "Whether to use spot instances for the Auto Scaling Group"
  type        = bool
  default     = true
}

variable "user_data_file" {
  description = "Path to the user data script file"
  type        = string
}

variable "key_pair_name" {
  description = "Key pair name for SSH access to instances"
  type        = string
}

variable "additional_sg_ids" {
  description = "List of additional security group IDs to attach to the Auto Scaling Group instances"
  type        = list(string)
  default     = []
}

variable "lifecycle_function" {
  description = "ARN and name of the Lambda function to handle lifecycle actions"
  type = object({
    arn  = string
    name = string
  })
}
