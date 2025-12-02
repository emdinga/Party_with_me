terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "party/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}