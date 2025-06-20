## Security Group for AutoScaling Group
resource "aws_security_group" "asg" {
  name        = "${var.prefix}-asg-sg"
  description = "Security group for AutoScaling Group instances"
  vpc_id      = var.vpc.id
  tags = {
    Name = "${var.prefix}-asg-sg"
  }
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.asg.id
  cidr_blocks       = [var.vpc.cidr]
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.asg.id
  cidr_blocks       = [var.vpc.cidr]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  security_group_id = aws_security_group.asg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
