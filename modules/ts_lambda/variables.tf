variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Lambda function (eg. 'nodejs22.x')\nThis module only supports Node.js runtimes."
  type        = string

  validation {
    condition     = startswith(var.runtime, "nodejs")
    error_message = "This module only supports Node.js runtimes."
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
