provider "aws" {
  region                  = var.aws_region
  shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
  profile                 = "default"
}
