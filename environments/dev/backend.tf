terraform {
  backend "s3" {
    bucket         = "chanindu-terraform-state-dev"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
