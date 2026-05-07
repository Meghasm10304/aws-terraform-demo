terraform {
  backend "s3" {
    bucket       = "meghana-terraform-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
