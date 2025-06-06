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
      "arn:aws:autoscaling:${local.region}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/${local.asg_name}",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.eni_failover.arn}:*",
    ]
  }
}

resource "aws_iam_policy" "eni_failover" {
  name        = "${local.prefix}-eni-failover-policy"
  description = "Policy for ENI failover Lambda function"
  policy      = data.aws_iam_policy_document.eni_failover.json
}

resource "aws_iam_role_policy_attachment" "eni_failover" {
  role       = aws_iam_role.eni_failover.name
  policy_arn = aws_iam_policy.eni_failover.arn
}
