data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/eni_failover/dist"
  output_path = "${path.module}/lambda/lambda.zip"
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

resource "aws_cloudwatch_log_group" "eni_failover" {
  name              = "/aws/lambda/${aws_lambda_function.eni_failover.function_name}"
  retention_in_days = 14
}
