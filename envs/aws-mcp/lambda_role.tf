data "aws_iam_policy_document" "trust_lambda" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  for_each = local.mcp_servers

  name               = "${local.prefix}-${each.key}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.trust_lambda.json

  tags = {
    Name = "${local.prefix}-${each.key}-lambda-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_exec_base" {
  for_each = local.mcp_servers

  policy_arn = "arn:aws:iam::aws:policy/service-role/${each.value.enable_vpc_config ? "AWSLambdaVPCAccessExecutionRole" : "AWSLambdaBasicExecutionRole"}"
  role       = aws_iam_role.lambda[each.key].name
}

data "aws_iam_policy_document" "mcp_exec" {
  for_each = {
    for key, value in local.mcp_servers :
    key => value
    if value.policy_statements != null && length(value.policy_statements) > 0
  }

  dynamic "statement" {
    for_each = toset(each.value.policy_statements)
    content {
      effect    = statement.value.effect != null ? statement.value.effect : "Allow"
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_role_policy" "mcp_exec" {
  for_each = {
    for key, value in local.mcp_servers :
    key => value
    if value.policy_statements != null && length(value.policy_statements) > 0
  }

  name   = "${local.prefix}-${each.key}-lambda-exec-policy"
  policy = data.aws_iam_policy_document.mcp_exec[each.key].json
  role   = aws_iam_role.lambda[each.key].name
}
