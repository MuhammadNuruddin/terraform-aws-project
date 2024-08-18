provider "aws" {
    region = "us-east-1"
}


resource "aws_s3_bucket" "my_s3_bucket" {
    bucket = "my-s3-bucket-xiiya-02"
}

resource "aws_iam_user" "my_iam_user" {
    name = "ziauddin_x11"
}
