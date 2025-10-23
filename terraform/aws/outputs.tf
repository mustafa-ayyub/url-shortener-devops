# We need to find the public IP of our running container
data "aws_network_interface" "service_eni" {
  # This makes sure Terraform waits for the service to be
  # at least partially running before searching for its IP.
  depends_on = [aws_ecs_service.app_service]
  
  # Find the network interface created by our ECS service
  filter {
    name   = "description"
    values = ["Amazon ECS vpc-id: ${aws_vpc.main.id}, cluster: ${aws_ecs_cluster.main.name}, service: ${aws_ecs_service.app_service.name}"]
  }
}

output "application_url" {
  description = "The URL of the deployed application"
  value       = "http://${data.aws_network_interface.service_eni.association[0].public_ip}:3000"
}