data "aws_ami" "al2023_arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023_arm64.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.bastion.key_name
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnets[local.use_az].id
  associate_public_ip_address = false
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  tags = {
    Name = "${local.prefix}-bastion-${local.use_az}"
  }
}

resource "aws_ec2_instance_connect_endpoint" "bastion" {
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnets[local.use_az].id
  security_group_ids = [
    aws_security_group.eic.id
  ]

  tags = {
    Name = "${local.prefix}-eic-endpoint-${substr(local.use_az, -1, 1)}"
  }
}
