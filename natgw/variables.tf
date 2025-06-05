locals {
  prefix = "arifuku-test"
  use_azs = [
    "ap-northeast-1a",
  ]
  availability_zones = {
    for az in local.use_azs : substr(az, -1, 1) => az
  }
}
