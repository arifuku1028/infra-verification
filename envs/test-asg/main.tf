data "aws_caller_identity" "current" {}

# NAT Gateway
module "natgw" {
  source                  = "../../modules/natgw"
  prefix                  = local.prefix
  region                  = local.region
  public_subnets          = data.terraform_remote_state.vpc.outputs.public_subnets
  private_route_table_ids = data.terraform_remote_state.vpc.outputs.private_route_table_ids
  azs_to_allocate = [
    local.az_to_allocate,
  ]
}

# Bastion host
module "bastion" {
  source = "../../modules/bastion"
  prefix = local.prefix
  region = local.region
  vpc = {
    id   = data.terraform_remote_state.vpc.outputs.vpc.id
    cidr = data.terraform_remote_state.vpc.outputs.vpc.cidr
  }
  subnets            = data.terraform_remote_state.vpc.outputs.private_subnets
  az_to_allocate     = local.az_to_allocate
  instance_type      = "t4g.micro"
  architecture       = "arm64"
  use_spot_instances = true
  key_pair_name      = aws_key_pair.ssh.key_name
}

# ENI with static private IPs for Auto Scaling Group failover
resource "aws_network_interface" "failover" {
  subnet_id   = data.terraform_remote_state.vpc.outputs.private_subnets["${local.region}${local.az_to_allocate}"].id
  private_ips = local.failover_ips

  tags = {
    Name = "${local.prefix}-failover-eni"
  }
}

# Lambda function for ENI failover
module "eni_failover_lambda" {
  source         = "../../modules/ts_lambda"
  prefix         = "${local.prefix}-eni-failover"
  runtime        = "nodejs22.x"
  ts_source_path = "${path.module}/lambda_source/eni_failover"
  env_vars = {
    "ENI_ID" = aws_network_interface.failover.id
  }
}

# Lambda execution policy
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
}

resource "aws_iam_role_policy" "eni_failover" {
  name   = "${local.prefix}-eni-failover-policy"
  policy = data.aws_iam_policy_document.eni_failover.json
  role   = module.eni_failover_lambda.lambda_role.name
}

# Auto Scaling Group
module "asg" {
  source   = "../../modules/asg_with_lifecycle_hook"
  prefix   = local.prefix
  asg_name = local.asg_name
  region   = local.region
  vpc = {
    id   = data.terraform_remote_state.vpc.outputs.vpc.id
    cidr = data.terraform_remote_state.vpc.outputs.vpc.cidr
  }
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  azs_to_allocate = [
    local.az_to_allocate,
  ]
  desired_capacity   = 1
  instance_type      = "t4g.small"
  architecture       = "arm64"
  use_spot_instances = true
  user_data_file     = "${path.module}/asg_user_data.sh"
  key_pair_name      = aws_key_pair.ssh.key_name
  additional_sg_ids = [
    module.bastion.bastion_sg_id
  ]
  lifecycle_function = {
    arn  = module.eni_failover_lambda.lambda_function.arn
    name = module.eni_failover_lambda.lambda_function.name
  }

  depends_on = [
    aws_iam_role_policy.eni_failover,
    aws_network_interface.failover,
  ]
}
