terraform {
  backend "s3" {
    bucket       = "arifuku-tfstate"
    key          = "test-vpc.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
