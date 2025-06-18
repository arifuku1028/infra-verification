data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "mcp" {
  for_each = toset(local.mcp_servers)

  name                 = "${local.prefix}-${each.key}-image-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Name = "${local.prefix}-${each.key}-image-repo"
  }
}

resource "aws_ecr_lifecycle_policy" "mcp" {
  for_each = toset(local.mcp_servers)

  repository = aws_ecr_repository.mcp[each.key].name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than ${local.ecr_image_retention_generation} generations"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = local.ecr_image_retention_generation
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
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

resource "aws_iam_policy" "push_ecr" {
  name        = "${local.prefix}-push-ecr-policy"
  description = "Policy to allow to push images to ECR repositories"
  policy      = data.aws_iam_policy_document.push_ecr.json
}
