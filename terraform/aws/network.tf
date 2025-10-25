resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "url-shortener-vpc"
    Project = "url-shortener"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "url-shortener-igw"
    Project = "url-shortener"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a" # e.g., us-east-1a
  map_public_ip_on_launch = true                  # Give services in here a public IP

  tags = {
    Name    = "url-shortener-public-subnet"
    Project = "url-shortener"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # To anywhere
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name    = "url-shortener-public-rt"
    Project = "url-shortener"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow inbound traffic for our app"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP traffic on port 3000 (our app)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # From anywhere on the internet
  }

  # Allow inbound Redis traffic on port 6379 (our database)
  # BEST PRACTICE: We restrict this to *only* our VPC.
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Only allow internal traffic
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "url-shortener-sg"
    Project = "url-shortener"
  }
}