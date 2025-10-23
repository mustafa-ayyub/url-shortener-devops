# Variable from GitHub Action
variable "docker_image_tag" {
  type        = string
  description = "The image tag (commit SHA) from the CI/CD pipeline"
}

# Variable from GitHub Action
variable "github_repo" {
  type        = string
  description = "The GitHub repository (e.g., mustafa-ayyub/url-shortener-devops)"
}

# Variable from GitHub Secrets
variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to."
  default = "eu-central-1"
  # We will get the value from the 'AWS_REGION' secret
  # If you want to run 'terraform apply' from your laptop,
  # you can set a default here, like: default = "eu-central-1"
}