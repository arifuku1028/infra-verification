## Lambda source code
resource "terraform_data" "build_lambda" {
  input = {
    src_hash = filesha256("${var.ts_source_path}/src/index.ts")
    pkg_hash = filesha256("${var.ts_source_path}/package.json")
  }

  provisioner "local-exec" {
    working_dir = var.ts_source_path
    command     = "npm install && npm run build"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.ts_source_path}/dist"
  output_path = "${path.root}/lambda_archive/${var.prefix}-function.zip"

  depends_on = [
    terraform_data.build_lambda
  ]
}

## Lambda function
resource "aws_lambda_function" "this" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.prefix}-function"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = var.runtime
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60

  environment {
    variables = var.env_vars
  }
}

## Cloudwatch log group for Lambda fucnction
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
}
