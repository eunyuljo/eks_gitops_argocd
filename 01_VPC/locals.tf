provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "${terraform.workspace}"
  region = "ap-northeast-2"

  # workspace별로 네트워크 정보 정의, 되도록 현재 운영중인 EKS Cluster 가 어디 네트워크에 배치되어있는지 한눈에 보이도록 구성
  # 각 network_info 내 변수는 구성할 workspace 이름을 따른다. 
  network_info = tomap({
    "gitops" = {
      vpc = {
        vpc_hand_made = "10.0.0.0/16"
        vpc_id = "vpc-00e7e31d7427ae524"
      }
      subnet = {
        subnet_hand_made = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
        subnet_make = {
          public_lb_subnet_hand_made  = ["subnet-0b8b02f5f559e65b6", "subnet-0e3639679afd9af3b", "subnet-06f3e33b54b7e9761"]
          private_subnet_hand_made    = ["subnet-044d9418d551a5386", "subnet-0bfe59237e8fdedd2", "subnet-0d6b3838ce2d68b53"]
        }
      }
    }
    "gitops2" = {
      vpc = {
        vpc_hand_made = "10.0.0.0/16"
        vpc_id = "vpc-00e7e31d7427ae524"
      }
      subnet = {
        subnet_hand_made = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
        subnet_make = {
          public_lb_subnet_hand_made  = ["subnet-0b8b02f5f559e65b6", "subnet-0e3639679afd9af3b", "subnet-06f3e33b54b7e9761"]
          private_subnet_hand_made    = ["subnet-09e4cacede78c904f", "subnet-0860d36c11539e02f", "subnet-0f8ccdc3624d4ab68"]
        }
      }
    }
  })

  # 각 저장된 항목은 현재 워크스페이스 정보를 기반으로 환경별 필요한 네트워크 정보만을 로컬 변수에 할당
  # 각 항목에 모두 접근하여 사용하게 되면 간섭될 여지가 큰 점을 고려하여 반영

  vpc_cidr             = local.network_info[terraform.workspace].vpc.vpc_hand_made
  vpc_id               = local.network_info[terraform.workspace].vpc.vpc_id
  azs                  = local.network_info[terraform.workspace].subnet.subnet_hand_made
  public_subnets_cidrs = local.network_info[terraform.workspace].subnet.subnet_make.public_lb_subnet_hand_made
  private_subnets_cidrs = local.network_info[terraform.workspace].subnet.subnet_make.private_subnet_hand_made


  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}