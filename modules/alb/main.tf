variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "ec2_target_asg_name" {}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = "var.vpc_id "   

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

  tags = {
    Name = "demo-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "demo_alb" {
  name               = "demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]   # Terraform SG
  subnets            = var.public_subnet_ids

  tags = {
    Name = "demo-alb"
  }

  lifecycle {
    ignore_changes = [subnets]
  }
}

