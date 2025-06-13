variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Lambda function (eg. 'nodejs22.x') This module only supports Node.js runtimes."
  type        = string

  validation {
    condition     = can(regex("^nodejs\\d+\\.x$", var.runtime))
    error_message = "Invalid runtime specified. This module only supports Node.js runtimes in the format 'nodejsX.x' where X is a major version number."
  }
}

variable "ts_source_path" {
  description = "Root path to the TypeScript source code for the Lambda function"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
}
