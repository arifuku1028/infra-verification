## Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name        = "${local.prefix}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc.id
  tags = {
    Name = "${local.prefix}-bastion-sg"
  }
}

resource "aws_security_group_rule" "allow_ssh_via_eic" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.eic.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
}

## Security Group for EIC Endpoint
resource "aws_security_group" "eic" {
  name        = "${local.prefix}-eic-sg"
  description = "Security group for EIC Endpoint"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc.id
  tags = {
    Name = "${local.prefix}-eic-sg"
  }
}

resource "aws_security_group_rule" "allow_to_vpc" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eic.id
  cidr_blocks = [
    data.terraform_remote_state.vpc.outputs.vpc.cidr
  ]
}
