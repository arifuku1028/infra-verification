resource "aws_codebuild_project" "mcp" {
  for_each = local.mcp_servers

  name          = "${local.prefix}-${each.key}-build-pj"
  description   = "Build and push ${each.key} image to ECR"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    type                        = "ARM_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = local.region
    }

    environment_variable {
      name  = "IMAGE_URI"
      value = aws_ecr_repository.mcp[each.key].repository_url
    }

    environment_variable {
      name  = "MCP_SERVER_NAME"
      value = each.key
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/awslabs/mcp.git"
    git_clone_depth = 1
    buildspec       = file("${path.module}/codebuild/buildspec.yml")
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  tags = {
    Name = "${local.prefix}-${each.key}-build-pj"
  }
}

resource "aws_cloudwatch_log_group" "codebuild" {
  for_each = local.mcp_servers

  name              = "/aws/codebuild/${aws_codebuild_project.mcp[each.key].name}"
  retention_in_days = 30

  tags = {
    Name = "/aws/codebuild/${aws_codebuild_project.mcp[each.key].name}"
  }
}

resource "terraform_data" "run_codebuild" {
  for_each = local.mcp_servers

  triggers_replace = {
    codebuild = aws_codebuild_project.mcp[each.key].arn
    buildspec = sha256(file("${path.module}/codebuild/buildspec.yml")),
  }

  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.mcp[each.key].name}"
  }

  depends_on = [
    aws_codebuild_project.mcp,
    aws_iam_role_policy.codebuild_push_ecr,
    aws_iam_role_policy_attachment.codebuild_logging,
  ]
}

resource "time_sleep" "wait_build" {
  for_each = local.mcp_servers

  triggers = {
    codebuild = aws_codebuild_project.mcp[each.key].arn
    buildspec = sha256(file("${path.module}/codebuild/buildspec.yml")),
  }

  create_duration = "120s"

  depends_on = [
    terraform_data.run_codebuild,
  ]
}
