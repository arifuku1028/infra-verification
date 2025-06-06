locals {
  prefix           = "arifuku-test"
  region           = "ap-northeast-1"
  az_to_allocate   = "c"
  instance_type    = "t3.medium"
  architecture     = "x86_64" # "arm64" or "x86_64"
  desired_capacity = 1
  failover_eni_ip_addresses = [
    "172.18.12.93",
    "172.18.12.99",
    "172.18.12.106",
  ]
}
