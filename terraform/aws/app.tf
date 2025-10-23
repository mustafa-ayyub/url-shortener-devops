resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "ecs-task-execution-role"
    Project = "url-shortener"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "url-shortener-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "url-shortener-app"
      image = "ghcr.io/${var.github_repo}:${var.docker_image_tag}"
      portMappings = [
        {
          containerPort = 3000
        }
      ],
      environment = [
        {
          name  = "REDIS_URL"
          value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ],
      essential = true
    }
  ])

  tags = {
    Name    = "url-shortener-task"
    Project = "url-shortener"
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "url-shortener-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.app_sg.id]
    assign_public_ip = true # Give it a public IP
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  depends_on = [aws_elasticache_cluster.redis]

  tags = {
    Name    = "url-shortener-service"
    Project = "url-shortener"
  }
}