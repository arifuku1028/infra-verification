data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-${var.architecture}"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnets["${var.region}${var.az_to_allocate}"].id
  associate_public_ip_address = false
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  dynamic "instance_market_options" {
    for_each = var.use_spot_instances ? ["enable"] : []
    content {
      market_type = "spot"
      spot_options {
        spot_instance_type             = "persistent"
        instance_interruption_behavior = "stop"
      }
    }
  }

  tags = {
    Name = "${var.prefix}-bastion-${var.az_to_allocate}"
  }
}

resource "aws_ec2_instance_connect_endpoint" "bastion" {
  subnet_id = var.subnets["${var.region}${var.az_to_allocate}"].id
  security_group_ids = [
    aws_security_group.eic.id
  ]

  tags = {
    Name = "${var.prefix}-eic-endpoint-${var.az_to_allocate}"
  }
}
