terraform {

  # 일반적인 환경변수를 정의하는 폴더 - 하나의 폴더에서 workspace별 vpc 내용만 담고 있는 terraform.tfstate 파일
  backend "s3" {
    region         = "ap-northeast-2"
    bucket         = "terraform-backend-gitops20250515032217344400000001"
    key            = "vpc/terraform.tfstate"
    dynamodb_table = "terraform_state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0, < 6.0.0"
    }
  }
}