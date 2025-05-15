terraform {
  # 일반적인 환경변수를 정의하는 폴더 - 하나의 폴더에서 workspace별 eks 내용만 담고 있는 terraform.tfstate 파일
  backend "s3" {
    region         = "ap-northeast-2"
    bucket         = "terraform-backend-gitops20250515032217344400000001"
    key            = "eks/terraform.tfstate"
    dynamodb_table = "terraform_state"
  }
}


######################### Backend #########################

locals {
####### V2 ########
  # 현재 워크스페이스를 기준으로, 동일한 workspace의 이름의 backend를 참고할 수 있도록 생성해주었다.

  # backend
  workspace_state_mapping = {
    "${terraform.workspace}" = "env:/${terraform.workspace}/backend/terraform.tfstate"
    "default"    = "env:/default/terraform.tfstate"
    }
  current_state_key = lookup(local.workspace_state_mapping, terraform.workspace, "default/terraform.tfstate")

  # vpc
  workspace_state_vpc_mapping = {
    "${terraform.workspace}" = "env:/${terraform.workspace}/vpc/terraform.tfstate"
    "default"    = "env:/default/terraform.tfstate"
    }
  current_state_vpc_key = lookup(local.workspace_state_vpc_mapping, terraform.workspace, "default/terraform.tfstate")
}

####### V2 ########

data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket = "terraform-backend-gitops20250515032217344400000001"  # S3 버킷 이름
    key    = local.current_state_key                       # 현재 워크스페이스에 해당하는 상태 파일 경로
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-backend-gitops20250515032217344400000001"  # S3 버킷 이름
    key    = local.current_state_vpc_key                       # 현재 워크스페이스에 해당하는 상태 파일 경로
    region = "ap-northeast-2"
  }
}








####### V1 ########
  # workspace_state_mapping = {
  #   "workspace1" = "env:/workspace1/backend/terraform.tfstate"
  #   "workspace2" = "env:/workspace2/backend/terraform.tfstate"
  #   "default"    = "env:/default/terraform.tfstate"
  #   }
  # current_state_key = lookup(local.workspace_state_mapping, terraform.workspace, "default/terraform.tfstate")

  # workspace_state_vpc_mapping = {
  #   "workspace1" = "env:/workspace1/vpc/terraform.tfstate"
  #   "workspace2" = "env:/workspace2/vpc/terraform.tfstate"
  #   "default"    = "env:/default/terraform.tfstate"
  #   }
  # current_state_vpc_key = lookup(local.workspace_state_vpc_mapping, terraform.workspace, "default/terraform.tfstate")


####### V1 ########

# data "terraform_remote_state" "Backend" {
#   backend = "local"
#   config = {
#     path = "../00_Backend/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
#   }
# }

# data "terraform_remote_state" "vpc" {
#   backend = "local"
#   config = {
#     path = "../01_VPC/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
#   }
# }