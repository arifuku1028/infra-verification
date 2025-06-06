locals {
  prefix           = "arifuku-test"
  region           = "ap-northeast-1"
  az_to_allocate   = "c"
  instance_type    = "t4g.micro"
  desired_capacity = 1
  failover_eni_ip_addresses = [
    "172.18.12.93",
    "172.18.12.106",
  ]
}
