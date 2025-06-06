resource "aws_network_interface" "failover" {
  subnet_id   = data.terraform_remote_state.vpc.outputs.private_subnets["${local.region}${local.az_to_allocate}"].id
  private_ips = local.failover_eni_ip_addresses
  security_groups = [
    aws_security_group.asg.id,
  ]
  tags = {
    Name = "${local.prefix}-failover-eni"
  }
}
