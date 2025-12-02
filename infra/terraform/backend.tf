terraform {
  backend "s3" {
    bucket         = "party-terraform-state-711387123965"
    key            = "party/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}