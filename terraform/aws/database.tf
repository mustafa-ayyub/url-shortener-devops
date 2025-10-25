resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.public.id]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id         = "url-shortener-redis"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name    = "url-shortener-redis"
    Project = "url-shortener"
  }
}