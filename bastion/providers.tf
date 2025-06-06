provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Environment = "test"
      ManagedBy   = "Terraform"
      Owner       = "hi-arifuku"
    }
  }
}
