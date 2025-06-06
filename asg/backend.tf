terraform {
  backend "s3" {
    bucket       = "arifuku-tfstate"
    key          = "test-asg.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "arifuku-tfstate"
    key    = "test-vpc.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "arifuku-tfstate"
    key    = "test-bastion.tfstate"
    region = "ap-northeast-1"
  }
}
