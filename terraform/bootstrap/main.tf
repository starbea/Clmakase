######################################################
# Terraform Remote State Backend Module
#
# 구성:
# 1. S3 Bucket                  - Terraform State 파일 저장
# 2. S3 Bucket Versioning       - State 파일 버전 관리
# 3. S3 Server Side Encryption  - State 파일 암호화
# 4. S3 Public Access Block     - 외부 공개 차단
# 5. DynamoDB Table             - Terraform State Lock 관리
######################################################

######################################################
# S3 Bucket
# - Terraform 상태 파일(terraform.tfstate)을 저장하는 버킷
######################################################
resource "aws_s3_bucket" "tfstate" {
  bucket = var.state_bucket_name
  
  force_destroy = true
}

######################################################
# S3 Bucket Versioning
# - Terraform state 변경 이력을 버전으로 관리
# - 실수로 state가 덮어써져도 이전 버전 복구 가능
######################################################
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

######################################################
# S3 Server Side Encryption
# - Terraform state 파일을 서버 측에서 자동 암호화
# - 민감 정보(리소스 정보, password 등) 보호
######################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

######################################################
# S3 Public Access Block
# - Terraform state 버킷의 외부 공개 방지
# - 퍼블릭 접근을 완전히 차단하여 보안 강화
######################################################
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

######################################################
# DynamoDB Table
# - Terraform State Lock 관리
# - 여러 사용자가 동시에 terraform apply 실행하는 것을 방지
######################################################
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}