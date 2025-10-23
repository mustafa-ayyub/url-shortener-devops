# URL Shortener - DevOps Project

## Description

This project implements a simple URL shortener microservice using Node.js, Express, and Redis. It serves as a practical example for building a complete DevOps pipeline, including containerization with Docker, CI/CD automation with GitHub Actions, and Infrastructure as Code (IaC) using Terraform for deployment to AWS.

## Features

* Shortens long URLs into unique short codes.
* Redirects users from the short URL to the original long URL.
* Uses Redis for fast storage and retrieval of URL mappings.

## Getting Started (Local Development)

### Prerequisites

* [Docker](https://www.docker.com/products/docker-desktop/) installed and running.
* [Docker Compose](https://docs.docker.com/compose/install/) installed.

### Running Locally

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/mustafa-ayyub/url-shortener-devops.git](https://github.com/mustafa-ayyub/url-shortener-devops.git)
    cd url-shortener-devops
    ```

2.  **Build and start the services:**
    This command will build the Node.js application image (using `Dockerfile`) and start both the application container and a Redis container.
    ```bash
    docker-compose up --build
    ```

3.  **Access the application:**
    The service will be available at [http://localhost:3000](http://localhost:3000).

4.  **Stopping the services:**
    Press `Ctrl+C` in the terminal where `docker-compose` is running, then run:
    ```bash
    docker-compose down
    ```

## CI/CD Pipeline (GitHub Actions)

This project uses GitHub Actions for Continuous Integration (CI) and Continuous Deployment (CD). The workflow is defined in `.github/workflows/ci.yml`.

### Workflow Steps:

1.  **Trigger:** Runs on every push to any branch (`**`).
2.  **Build & Test Job (`build-and-test`):**
    * Runs on all branches.
    * Checks out the code.
    * Sets up Node.js 20.
    * Installs dependencies using `npm ci`.
    * Runs the linter (`npm run lint`).
    * Runs unit tests (`npm run test`).
    * Logs into GitHub Container Registry (GHCR).
    * Builds the Docker image using the `Dockerfile`.
    * Pushes the Docker image to GHCR, tagged with the commit SHA.
3.  **Deploy to AWS Job (`deploy-to-aws`):**
    * Runs **only** when changes are pushed to the `master` branch.
    * Requires the `build-and-test` job to succeed first.
    * Checks out the code.
    * Configures AWS credentials securely using OIDC (requires AWS IAM setup).
    * Sets up Terraform.
    * Runs `terraform init` in the `terraform/aws` directory.
    * Runs `terraform apply -auto-approve`, passing the Docker image tag and repository name as variables. This deploys the infrastructure defined in the `.tf` files.

## Infrastructure as Code (Terraform for AWS)

The AWS infrastructure is managed using Terraform, with configuration files located in the `terraform/aws/` directory.

### Resources Created:

* **Networking:** VPC, Public Subnet, Internet Gateway, Route Table, Security Group (allowing traffic on ports 3000 and 6379).
* **Database:** AWS ElastiCache for Redis (`cache.t3.micro` - Free Tier eligible).
* **Application:**
    * AWS ECS Cluster (`url-shortener-cluster`).
    * AWS IAM Role for ECS Task Execution.
    * AWS ECS Task Definition (specifies the container image, CPU/Memory - Fargate Free Tier eligible).
    * AWS ECS Service (runs and manages the application container on Fargate, assigns a public IP).

### Deployment

Deployment to AWS happens automatically when code is pushed or merged to the `master` branch via the GitHub Actions workflow.

### Destroying Infrastructure

**Important:** To avoid unwanted AWS charges after you are finished, you must destroy the infrastructure. You can do this locally (if you have AWS credentials configured and Terraform installed):

```bash
cd terraform/aws
terraform destroy -auto-approve \
  -var="docker_image_tag=any-tag-will-do" \
  -var="github_repo=mustafa-ayyub/url-shortener-devops" \
  -var="aws_region=YOUR_REGION"