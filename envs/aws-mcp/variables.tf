locals {
  prefix = "arifuku-test-mcp"
  region = "ap-northeast-1"
  github_repo = {
    owner = "arifuku1028"
    repo  = "infra-verification"
  }
  mcp_servers = [
    "dynamodb-mcp-server",
    "mysql-mcp-server",
    "postgres-mcp-server",
  ]
  ecr_image_retention_generation = 3
}
