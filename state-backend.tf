# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "meghana-terraform-state"

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "infra"
  }
}
# Enable versioning (separate resource)
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption (separate resource)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
