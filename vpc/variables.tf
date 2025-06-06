locals {
  prefix   = "arifuku-test"
  region   = "ap-northeast-1"
  vpc_cidr = "172.18.0.0/16"
  public_subnets = {
    "a" = "172.18.0.0/26"
    "c" = "172.18.0.64/26"
    "d" = "172.18.0.128/26"
  }
  private_subnets = {
    "a" = "172.18.12.0/26"
    "c" = "172.18.12.64/26"
    "d" = "172.18.12.128/26"
  }
}
