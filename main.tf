provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id   # must resolve to vpc-0ad08eff733772e77
  public_subnet_ids   = module.vpc.public_subnet_ids
  ec2_target_asg_name = module.ec2.asg_name
}

module "monitoring" {
  source            = "./modules/monitoring"
  vpc_id            = module.vpc.vpc_id
  state_bucket_name = aws_s3_bucket.terraform_state.bucket
}
