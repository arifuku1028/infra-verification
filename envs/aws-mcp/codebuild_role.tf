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

data "aws_iam_policy_document" "push_ecr" {
  statement {
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:BatchGetImage"
    ]
    resources = [
      for repo in aws_ecr_repository.mcp :
      repo.arn
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_push_ecr" {
  name   = "${local.prefix}-push-ecr-policy"
  policy = data.aws_iam_policy_document.push_ecr.json
  role   = aws_iam_role.codebuild.name
}
