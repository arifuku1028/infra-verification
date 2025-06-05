provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Environment = "test"
      ManagedBy   = "Terraform"
      Owner       = "hi-arifuku"
    }
  }
}
