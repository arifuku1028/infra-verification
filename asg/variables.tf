locals {
  prefix            = "arifuku-test"
  desired_capacity  = 1
  instance_type     = "t4g.micro"
  use_az            = "ap-northeast-1a"
  region            = substr(local.use_az, 0, length(local.use_az) - 1)
  asg_instance_name = "${local.prefix}-asg-instance"
}
