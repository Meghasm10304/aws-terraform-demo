variable "vpc_id" {}

variable "public_subnet_ids" {
  type = list(string)
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "demo-ec2-sg"
  }
}

# Launch Template
resource "aws_launch_template" "demo_lt" {
  name_prefix   = "demo-lt"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  key_name      = "vpc-public-1"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd awscli
              systemctl start httpd
              systemctl enable httpd

              # Deploy index.html
              cat <<EOT > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>AWS Terraform Demo Project</title>
                <style>
                  body { font-family: Arial, sans-serif; background:#f9fafc; margin:0; padding:0; }
                  header { background:#004aad; color:#fff; padding:20px; text-align:center; }
                  section { padding:40px; max-width:900px; margin:auto; }
                  h2 { color:#004aad; }
                  .card { background:#fff; padding:20px; margin-bottom:20px; border-radius:8px; box-shadow:0 2px 6px rgba(0,0,0,0.1); }
                  footer { background:#004aad; color:#fff; text-align:center; padding:15px; margin-top:40px; }
                </style>
              </head>
              <body>
                <header>
                  <h1>AWS Terraform Demo Project</h1>
                </header>
                <section>
                  <div class="card">
                    <h2>Overview</h2>
                    <p>This project provisions scalable AWS infrastructure using Terraform: VPC, subnets, EC2 Auto Scaling Group, and an Application Load Balancer.</p>
                  </div>
                  <div class="card">
                    <h2>Architecture</h2>
                    <ul>
                      <li>Custom VPC with public and private subnets</li>
                      <li>EC2 instances managed by Auto Scaling Group</li>
                      <li>Application Load Balancer distributing traffic</li>
                      <li>Security groups for controlled access</li>
                    </ul>
                    <img src="architecture.png" alt="Architecture Diagram" style="max-width:100%; border:1px solid #ccc; border-radius:8px; margin-top:20px;">
                  </div>
                  <div class="card">
                    <h2>Features</h2>
                    <ul>
                      <li>Infrastructure as Code with Terraform modules</li>
                      <li>Scalable and highly available setup</li>
                      <li>Load balancing across multiple AZs</li>
                    </ul>
                  </div>
                </section>
                <footer>
                  <p>&copy; 2026 Meghana | AWS Terraform Demo Project</p>
                </footer>
              </body>
              </html>
              EOT

              # Download image from S3
              aws s3 cp s3://meghana-terraform-demo-bucket/architecture.png /var/www/html/architecture.png
              EOF
  )

 vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "demo-ec2"
    }
  }

  iam_instance_profile {
    name = "ec2-s3-read-role"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "demo_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1

  vpc_zone_identifier  = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.demo_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "demo-asg"
    propagate_at_launch = true
  }
}
