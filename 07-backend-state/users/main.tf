terraform {
  backend "s3" {
    bucket = "dev-applications-backend-state-nexha"
    key = "07-backend-state-users-dev"
    region = "us-east-1"
    dynamodb_table = "dev_application_locks"
    encrypt = true
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_user" "my_iam_user" {
  name = "Ziauddin"
}


