# Configure the AWS Provider
provider "aws" {
  region = var.aws_region # Use the region variable
}

# This is the "cluster" or "group" for our app.
# We put it here because it's the top-level "service" resource.
resource "aws_ecs_cluster" "main" {
  name = "url-shortener-cluster"
  tags = {
    Name    = "url-shortener-cluster"
    Project = "url-shortener"
  }
}