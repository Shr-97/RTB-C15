provider "aws" { region = "us-east-1" }

resource "aws_ecr_repository" "app_repo" {
  name = "devops-rtb-c15-app"
}

resource "aws_ecs_cluster" "main" {
  name = "rtb-cluster"
}

# (Add ECS Service and Task Definitions here focusing on EC2 launch type)
