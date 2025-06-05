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

resource "aws_iam_role" "eni_failover" {
  name               = "${local.prefix}-eni-failover-function-role"
  assume_role_policy = data.aws_iam_policy_document.trust_lambda.json
}

data "aws_iam_policy_document" "eni_failover" {
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
    ]
    resources = [
      aws_network_interface.failover.arn,
      "arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*",
    ]
  }

  statement {
    actions = [
      "autoScaling:CompleteLifecycleAction",
    ]
    resources = [
      aws_autoscaling_group.this.arn,
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.eni_failover.arn,
      "${aws_cloudwatch_log_group.eni_failover.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "eni_failover" {
  name   = "${local.prefix}-eni-failover-policy"
  role   = aws_iam_role.eni_failover.id
  policy = data.aws_iam_policy_document.eni_failover.json
}
