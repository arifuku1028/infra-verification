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

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.prefix}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.trust_lambda.json

  tags = {
    Name = "${local.prefix}-lambda-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_exec_vpc_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}
