provider "aws" {
  region = local.region
}
data "aws_availability_zones" "available" {}


locals {
  name   = "${terraform.workspace}"
  environment = terraform.workspace
  # karpenter 용 tag 추가 변수

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}


# EKS 구성하기 위한 입력값
locals {
  region                = data.terraform_remote_state.backend.outputs.defaults.region
  cluster_version       = data.terraform_remote_state.backend.outputs.cluster_version
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr              = data.terraform_remote_state.vpc.outputs.vpc_cidr
  private_subnets_cidrs = data.terraform_remote_state.vpc.outputs.private_subnets_cidrs
}



# Addons - External-DNS 
data "aws_route53_zone" "sub" {
  name = "${local.hosted_zone_name}"
}

locals { 
  hosted_zone_name           = "example-mzc.com"
  argocd_route53_weight      = "100"
  workspace_weights = {
    workspace1 = "100"
    workspace2 = "0"
    }
    # 트래픽 가중치는 기본적으로 0으로 세팅하고, metadata 정보에서 변경 
  route53_weight = lookup(local.workspace_weights, terraform.workspace, "0")
}


# ingress type
locals {
  ingress_type               = "alb" # or "nginx"
}

# Addons - Karpenter 
locals { 
  karpenter_tag = { "karpenter.sh/discovery" = "${terraform.workspace}" } 
}

