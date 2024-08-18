provider "aws" {
  region = "us-east-1"
}

# S3 Bucket - use it to store remote state
resource "aws_s3_bucket" "nexa_backend_state" {
  bucket = "dev-applications-backend-state-nexha"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.nexa_backend_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.nexa_backend_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Locking - to stop concurrent change - Dynamo DB

resource "aws_dynamodb_table" "nexa_backend_lock" {
  name         = "dev_application_locks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}