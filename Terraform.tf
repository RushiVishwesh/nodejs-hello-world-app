provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAXYKJSPFI4WS24VFD"
  secret_key = "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"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "hello-world-vpc"
  }
}

resource "aws_subnet" "hello_world_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "hello_world_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu            = 256
  memory         = 512
  container_definitions = jsonencode([
    {
      name           = "hello-world-container"
      image          = "vishweshrushi/hello-world:latest"
      cpu            = 256
      memory         = 512
      essential      = true
    }
  ])
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_world.arn  # Use ARN here
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.hello_world_subnet.id]
    security_groups = [aws_security_group.hello_world_sg.id]
  }
}
