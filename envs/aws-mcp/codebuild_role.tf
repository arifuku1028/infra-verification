data "aws_iam_policy_document" "trust_codebuild" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${local.prefix}-codebuild-exec-role"
  assume_role_policy = data.aws_iam_policy_document.trust_codebuild.json

  tags = {
    Name = "${local.prefix}-codebuild-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild_logging" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.codebuild.name
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_push" {
  policy_arn = aws_iam_policy.push_ecr.arn
  role       = aws_iam_role.codebuild.name
}
