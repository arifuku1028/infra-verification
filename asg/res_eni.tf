resource "aws_network_interface" "failover" {
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnets[local.use_az].id
  private_ips = [
    cidrhost(data.terraform_remote_state.vpc.outputs.private_subnets[local.use_az].cidr, 4),
    cidrhost(data.terraform_remote_state.vpc.outputs.private_subnets[local.use_az].cidr, 5),
  ]
  security_groups = [
    aws_security_group.asg.id,
  ]
  tags = {
    Name = "${local.prefix}-failover-eni"
  }
}
