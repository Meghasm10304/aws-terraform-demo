# modules/alb/main.tf

variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "ec2_target_asg_name" {}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id

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
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "demo-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "demo_tg" {
  name     = "demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "demo-tg"
  }
}

# Listener (this was broken before)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.demo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_tg.arn
  }
}

# Attach ASG to Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.ec2_target_asg_name
  lb_target_group_arn    = aws_lb_target_group.demo_tg.arn
}
