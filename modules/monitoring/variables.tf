variable "vpc_id" {
  description = "The VPC ID to monitor"
  type        = string
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}
