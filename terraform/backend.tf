terraform {
  backend "s3" {
    bucket         = "shortlink-state-terraform" 
    key            = "shortlink/terraform.tfstate"
    region         = "ap-south-1"
    
    dynamodb_table = "shortlink-terraform-lock"
    encrypt        = true
  }
}