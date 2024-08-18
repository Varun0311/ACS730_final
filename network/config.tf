terraform {
  backend "s3" {
    bucket = "finalprojecr-vspal"
    key    = "Fianl-Project/network/terraform.tfstate"
    region = "us-east-1"
  }
}