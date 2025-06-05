locals {
  prefix   = "arifuku-test"
  vpc_cidr = "10.0.0.0/16"
  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d",
  ]
  availability_zones = {
    for index, az in local.azs : substr(az, -1, 1) => {
      name  = az
      index = index
    }
  }
}
