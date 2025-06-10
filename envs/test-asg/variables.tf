locals {
  prefix         = "arifuku-test"
  region         = "ap-northeast-1"
  az_to_allocate = "c"
  failover_ips = [
    "172.18.12.93",
    "172.18.12.99",
    "172.18.12.106",
  ]
  asg_name = "${local.prefix}-asg"
}
