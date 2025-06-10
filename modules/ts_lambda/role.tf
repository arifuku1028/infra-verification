data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "trust_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.prefix}-function-role"
  assume_role_policy = data.aws_iam_policy_document.trust_lambda.json
}

data "aws_iam_policy_document" "lambda_base" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.lambda.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "lambda_base" {
  name   = "${var.prefix}-lambda-base-policy"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda_base.json
}
