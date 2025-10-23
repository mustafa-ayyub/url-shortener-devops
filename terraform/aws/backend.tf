terraform {
  backend "s3" {
    bucket = "terraform-state-ma-12345"
    region = "eu-central-1"

  }
}