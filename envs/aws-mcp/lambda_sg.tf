resource "aws_security_group" "lambda" {
  name        = "${local.prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc.id
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.lambda.id
  description       = "Allow all outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  cidr_blocks       = ["0.0.0.0/0"]
}
