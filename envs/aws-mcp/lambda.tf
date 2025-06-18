resource "aws_lambda_function" "mcp" {
  for_each = toset(local.mcp_servers)

  function_name = "${local.prefix}-${each.key}-function"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.mcp[each.key].repository_url}:latest"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 900

  vpc_config {
    security_group_ids = [
      aws_security_group.lambda.id
    ]
    subnet_ids = [
      for subnet in data.terraform_remote_state.vpc.outputs.private_subnets :
      subnet.id
    ]
  }

  tags = {
    Name = "${local.prefix}-${each.key}-lambda"
  }

  lifecycle {
    ignore_changes = [
      image_uri,
    ]
  }

  depends_on = [
    time_sleep.wait_build,
  ]
}

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = toset(local.mcp_servers)

  name              = "/aws/lambda/${aws_lambda_function.mcp[each.key].function_name}"
  retention_in_days = 30

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.mcp[each.key].function_name}"
  }
}
