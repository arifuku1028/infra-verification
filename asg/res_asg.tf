## Launch Template
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

resource "aws_launch_template" "this" {
  name_prefix            = "${local.prefix}-launch-template-"
  instance_type          = local.instance_type
  key_name               = data.terraform_remote_state.bastion.outputs.key_pair_name
  image_id               = data.aws_ami.al2023_arm64.id
  vpc_security_group_ids = [aws_security_group.asg.id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    secondary_eni_mac = aws_network_interface.failover.mac_address
  }))
  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = local.asg_instance_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


## Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name             = "${local.prefix}-asg"
  desired_capacity = local.desired_capacity
  max_size         = local.desired_capacity + 1
  min_size         = local.desired_capacity
  vpc_zone_identifier = [
    data.terraform_remote_state.vpc.outputs.private_subnets[local.use_az].id
  ]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}
