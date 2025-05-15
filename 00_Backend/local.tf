# backend 를 통해 전달해야하는 환경변수는 명료한 것만

locals {
  defaults = {
    region = "ap-northeast-2"
    name = "${terraform.workspace}"
  }

  global_tag = {}

  eks_info = tomap({
    "gitops" = {
      cluster_version = "1.30"
      nodegroup = {}
    }
    "gitops2" = {
      cluster_version = "1.31"
      nodegroup = {}
    }
  })

  # 각 terraform workspace 별로 분류하도록 선언한 내용을 output으로 출력한다.
  # eks_info 내에서 접근하는 경우보다 나을 것아 배치
  cluster_version = local.eks_info[terraform.workspace].cluster_version
}
