## AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-${var.architecture}"]
  }

  filter {
    name   = "architecture"
    values = ["${var.architecture}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


## Launch Template for AutoScaling Group
resource "aws_launch_template" "this" {
  name          = "${var.prefix}-launch-template"
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  image_id      = data.aws_ami.al2023.id
  vpc_security_group_ids = concat(
    [aws_security_group.asg.id],
    var.additional_sg_ids,
  )
  user_data              = filebase64(var.user_data_file)
  update_default_version = true

  dynamic "instance_market_options" {
    for_each = var.use_spot_instances ? ["enable"] : []
    content {
      market_type = "spot"
      spot_options {
        spot_instance_type             = "one-time"
        instance_interruption_behavior = "terminate"
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-asg-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


## AutoScaling Group
resource "aws_autoscaling_group" "this" {
  name             = var.asg_name
  desired_capacity = var.desired_capacity
  max_size         = var.desired_capacity + 1
  min_size         = var.desired_capacity
  vpc_zone_identifier = [
    for az in var.azs_to_allocate :
    var.subnets["${var.region}${az}"].id
  ]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  initial_lifecycle_hook {
    name                 = "attach-eni-hook"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
  }

  depends_on = [
    aws_cloudwatch_event_target.launch,
    aws_lambda_permission.allow_eventbridge,
  ]
}
