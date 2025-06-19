locals {
  prefix = "arifuku-test-mcp"
  region = "ap-northeast-1"
  github_repo = {
    owner = "arifuku1028"
    repo  = "infra-verification"
  }
  ecr_image_retention_generation = 3
  mcp_servers = {
    "cloudwatch-logs-mcp-server" = {
      description       = "Discovering log groups and metadata about them within your AWS account or accounts connected by CloudWatch Cross Account Observability."
      enable_vpc_config = false
      policy_statements = [
        {
          effect = "Allow"
          actions = [
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "logs:StartQuery",
            "logs:StopQuery",
          ]
          resources = ["*"]
        }
      ]
    }
    "dynamodb-mcp-server" = {
      description       = "The official MCP Server for interacting with AWS DynamoDB provides a comprehensive set of tools for managing DynamoDB resources."
      enable_vpc_config = false
      policy_statements = [
        {
          effect = "Allow"
          actions = [
            "dynamodb:*",
          ]
          resources = ["*"]
        }
      ]
    }
    "mysql-mcp-server" = {
      description       = "Converting human-readable questions and commands into structured MySQL-compatible SQL queries and executing them against the configured Aurora MySQL database."
      enable_vpc_config = true
      policy_statements = []
    }
  }
}
