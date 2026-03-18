provider "aws" {
  region = "us-east-1"
}

# 1. Create the ECR Repository (where Docker images are stored)
resource "aws_ecr_repository" "poc_repo" {
  name = "rtb-c15-repo"
}

# 2. Create the ECS Cluster
resource "aws_ecs_cluster" "poc_cluster" {
  name = "rtb-ecs-cluster"
}

# (Note: For a full EC2 setup, you'd add Auto Scaling Groups here)
