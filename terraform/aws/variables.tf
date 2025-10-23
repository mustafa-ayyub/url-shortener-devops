variable "docker_image_tag" {
  type        = string
  description = "The image tag (commit SHA) from the CI/CD pipeline"
}

variable "github_repo" {
  type        = string
  description = "The GitHub repository (e.g., mustafa-ayyub/url-shortener-devops)"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to."
  default = "eu-central-1"
}