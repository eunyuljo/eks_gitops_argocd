resource "aws_s3_bucket" "backend" {
  bucket_prefix = "terraform-backend-gitops"

  tags = {
    Name        = "Terraform Backend GitOps"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_versioning" "backend" {

  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {

  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {

  name                        = "terraform_state_gitops"
  deletion_protection_enabled = true
  read_capacity               = 5
  write_capacity              = 5
  hash_key                    = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "Terraform Backend Gitops"
    Environment = terraform.workspace
  }
}
