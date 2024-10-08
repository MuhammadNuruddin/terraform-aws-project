variable "iam_user_name_prefix" {
    default = "ziauddin_x11"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_user" "my_iam_users" {
    count = 2
    name = "${var.iam_user_name_prefix}_${count.index}"
}