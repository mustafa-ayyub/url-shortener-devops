provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "main" {
  name = "url-shortener-cluster"
  tags = {
    Name    = "url-shortener-cluster"
    Project = "url-shortener"
  }
}