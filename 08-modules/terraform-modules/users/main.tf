variable "environment" {
  default = "default"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_user" "my_iam_user" {
    name = "ziauddin_x11_${var.environment}"
}
