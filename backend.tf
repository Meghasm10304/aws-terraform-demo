terraform {
  backend "s3" {
    bucket         = "meghana-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"   # must match bucket region
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
