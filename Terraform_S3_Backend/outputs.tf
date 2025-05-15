# S3 버킷 이름 출력
output "s3_bucket_name" {
  value       = aws_s3_bucket.backend.id
  description = "생성된 S3 버킷 이름"
}

# DynamoDB 테이블 이름 출력
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "생성된 DynamoDB 테이블 이름"
}