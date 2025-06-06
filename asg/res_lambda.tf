## Lambda function for ENI failover
resource "terraform_data" "build_lambda" {
  input = {
    src_hash      = filesha256("${path.module}/lambda/eni_failover/src/index.ts")
    pkg_hash      = filesha256("${path.module}/lambda/eni_failover/package.json")
    pkg_lock_hash = filesha256("${path.module}/lambda/eni_failover/package-lock.json")
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/lambda/eni_failover"
    command     = "npm install && npm run build"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/eni_failover/dist"
  output_path = "${path.module}/lambda/lambda.zip"

  depends_on = [
    terraform_data.build_lambda
  ]
}

resource "aws_lambda_function" "eni_failover" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.prefix}-eni-failover-function"
  role             = aws_iam_role.eni_failover.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      ENI_ID = aws_network_interface.failover.id
    }
  }

  depends_on = [
    aws_network_interface.failover,
  ]
}

## Lambda resource based policy
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "${local.prefix}-eni-failover-permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eni_failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.launch.arn
}

## Cloudwatch log group for Lambda
resource "aws_cloudwatch_log_group" "eni_failover" {
  name              = "/aws/lambda/${aws_lambda_function.eni_failover.function_name}"
  retention_in_days = 14
}
