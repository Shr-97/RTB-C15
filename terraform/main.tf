provider "aws" {
  region = "us-east-1"
}

# 1. ECR Repository for your Docker Images
resource "aws_ecr_repository" "poc_repo" {
  name                 = "rtb-c15-repo"
  force_delete         = true # Allows terraform destroy to work even if images exist
}

# 2. ECS Cluster
resource "aws_ecs_cluster" "poc_cluster" {
  name = "rtb-ecs-cluster"
}

# 3. IAM Role for ECS Task Execution
# This allows ECS to pull images from ECR and send logs to CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "rtb-c15-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 4. ECS Task Definition (The Blueprint)
resource "aws_ecs_task_definition" "app_task" {
  family                   = "rtb-c15-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "rtb-app"
    image     = "${aws_ecr_repository.poc_repo.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

# 5. ECS Service (The Manager)
resource "aws_ecs_service" "app_service" {
  name            = "rtb-c15-service"
  cluster         = aws_ecs_cluster.poc_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    # Replace these with your actual default Subnet IDs from your AWS console
    # You can find these in VPC > Subnets
    subnets          = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"] 
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_web.id]
  }
}

# 6. Security Group to allow Web Traffic on Port 80
resource "aws_security_group" "allow_web" {
  name        = "rtb-c15-sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
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
