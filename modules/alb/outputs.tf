output "alb_arn" {
  value = aws_lb.demo_alb.arn
}

output "alb_dns_name" {
  value = aws_lb.demo_alb.dns_name
}
