resource "aws_sns_topic" "alarms_topic" {
  name = "url-shortener-alarms"

  tags = {
    Name    = "url-shortener-alarms-topic"
    Project = "url-shortener"
  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarms_topic.arn
  protocol  = "email"
  endpoint  = "mustafaayyub.dev@gmail.com" #
}


resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "url-shortener-ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "60"      

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app_service.name
  }

  alarm_description = "Alarm when ECS service CPU utilization exceeds 60%"
  alarm_actions     = [aws_sns_topic.alarms_topic.arn]
  ok_actions        = [aws_sns_topic.alarms_topic.arn]

  tags = {
    Project = "url-shortener"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "url-shortener-ecs-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app_service.name
  }

  alarm_description = "Alarm when ECS service memory utilization exceeds 85%"
  alarm_actions     = [aws_sns_topic.alarms_topic.arn]
  ok_actions        = [aws_sns_topic.alarms_topic.arn]

  tags = {
    Project = "url-shortener"
  }
}