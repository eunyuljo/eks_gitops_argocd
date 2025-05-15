

locals {
  gitops_addons_url      = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  gitops_workload_url      = "${var.gitops_workload_org}/${var.gitops_workload_repo}"
  gitops_workload_basepath = var.gitops_workload_basepath
  gitops_workload_path     = var.gitops_workload_path
  gitops_workload_revision = var.gitops_workload_revision

  eks_cluster_domain = "${local.hosted_zone_name}" # for external-dns

  aws_addons = {
    enable_cert_manager                          = true
    enable_aws_efs_csi_driver                    = false
    enable_aws_fsx_csi_driver                    = false
    enable_aws_cloudwatch_metrics                = false 
    enable_aws_privateca_issuer                  = false
    enable_cluster_autoscaler                    = false
    enable_external_dns                          = true
    enable_external_secrets                      = true
    enable_aws_load_balancer_controller          = true
    enable_fargate_fluentbit                     = false
    enable_aws_for_fluentbit                     = true
    enable_aws_node_termination_handler          = false
    enable_karpenter                             = true
    enable_velero                                = false
    enable_aws_gateway_api_controller            = false
    enable_aws_ebs_csi_resources                 = true
    enable_aws_secrets_store_csi_driver_provider = false
    enable_ack_apigatewayv2                      = false
    enable_ack_dynamodb                          = false
    enable_ack_s3                                = false
    enable_ack_rds                               = false
    enable_ack_prometheusservice                 = false
    enable_ack_emrcontainers                     = false
    enable_ack_sfn                               = false
    enable_ack_eventbridge                       = false
  }
  oss_addons = {
    enable_argocd                          = true
    enable_argo_rollouts                   = true
    enable_argo_events                     = false
    enable_argo_workflows                  = false
    enable_cluster_proportional_autoscaler = false
    enable_gatekeeper                      = false
    enable_gpu_operator                    = false
    enable_ingress_nginx                   = true
    enable_kyverno                         = false
    enable_kube_prometheus_stack           = true
    enable_metrics_server                  = true
    enable_prometheus_adapter              = false
    enable_secrets_store_csi_driver        = false
    enable_vpa                             = false
    enable_kube_ops_view                   = true
  }

  
  addons = merge(
    local.aws_addons,
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = local.cluster_name }
  )

  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = local.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = local.vpc_id
    },
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    },
    {
      workload_repo_url      = local.gitops_workload_url
      workload_repo_basepath = local.gitops_workload_basepath
      workload_repo_path     = local.gitops_workload_path
      workload_repo_revision = local.gitops_workload_revision
    },
    {
      external_dns_policy        = "sync"
      route53_weight             = local.route53_weight
      argocd_route53_weight      = local.argocd_route53_weight
      ingress_type               = local.ingress_type
      eks_cluster_domain         = local.eks_cluster_domain
    }
  )

  argocd_apps  = {
    addons = file("${path.module}/bootstrap/addons.yaml") 
    workload = file("${path.module}/bootstrap/workloads.yaml") 
  }
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "github.com/gitops-bridge-dev/gitops-bridge-argocd-bootstrap-terraform?ref=v2.0.0"

  cluster = {
    cluster_name  = local.name
    environment   = local.environment
    metadata      = local.addons_metadata
    addons        = local.addons
  }

  apps = local.argocd_apps
}

################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks_al2023.cluster_name
  cluster_endpoint  = module.eks_al2023.cluster_endpoint
  cluster_version   = module.eks_al2023.cluster_version
  oidc_provider_arn = module.eks_al2023.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_cert_manager                 = local.aws_addons.enable_cert_manager
  enable_aws_efs_csi_driver           = local.aws_addons.enable_aws_efs_csi_driver
  enable_aws_fsx_csi_driver           = local.aws_addons.enable_aws_fsx_csi_driver
  enable_aws_cloudwatch_metrics       = local.aws_addons.enable_aws_cloudwatch_metrics
  enable_aws_privateca_issuer         = local.aws_addons.enable_aws_privateca_issuer
  enable_cluster_autoscaler           = local.aws_addons.enable_cluster_autoscaler
  enable_external_secrets             = local.aws_addons.enable_external_secrets
  enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  enable_fargate_fluentbit            = local.aws_addons.enable_fargate_fluentbit
  enable_aws_for_fluentbit            = local.aws_addons.enable_aws_for_fluentbit
  enable_aws_node_termination_handler = local.aws_addons.enable_aws_node_termination_handler
  enable_karpenter                    = local.aws_addons.enable_karpenter
  enable_velero                       = local.aws_addons.enable_velero
  enable_aws_gateway_api_controller   = local.aws_addons.enable_aws_gateway_api_controller


  enable_external_dns                 = local.aws_addons.enable_external_dns
  external_dns_route53_zone_arns      = [data.aws_route53_zone.sub.arn]

  tags = local.tags

}




  # aws_addons = {
  #   enable_cert_manager                          = try(var.addons.enable_cert_manager, false)
  #   enable_aws_efs_csi_driver                    = try(var.addons.enable_aws_efs_csi_driver, false)
  #   enable_aws_fsx_csi_driver                    = try(var.addons.enable_aws_fsx_csi_driver, false)
  #   enable_aws_cloudwatch_metrics                = try(var.addons.enable_aws_cloudwatch_metrics, false)
  #   enable_aws_privateca_issuer                  = try(var.addons.enable_aws_privateca_issuer, false)
  #   enable_cluster_autoscaler                    = try(var.addons.enable_cluster_autoscaler, false)
  #   enable_external_dns                          = try(var.addons.enable_external_dns, false)
  #   enable_external_secrets                      = try(var.addons.enable_external_secrets, false)
  #   enable_aws_load_balancer_controller          = try(var.addons.enable_aws_load_balancer_controller, false)
  #   enable_fargate_fluentbit                     = try(var.addons.enable_fargate_fluentbit, false)
  #   enable_aws_for_fluentbit                     = try(var.addons.enable_aws_for_fluentbit, false)
  #   enable_aws_node_termination_handler          = try(var.addons.enable_aws_node_termination_handler, false)
  #   enable_karpenter                             = try(var.addons.enable_karpenter, false)
  #   enable_velero                                = try(var.addons.enable_velero, false)
  #   enable_aws_gateway_api_controller            = try(var.addons.enable_aws_gateway_api_controller, false)
  #   enable_aws_ebs_csi_resources                 = try(var.addons.enable_aws_ebs_csi_resources, false)
  #   enable_aws_secrets_store_csi_driver_provider = try(var.addons.enable_aws_secrets_store_csi_driver_provider, false)
  #   enable_ack_apigatewayv2                      = try(var.addons.enable_ack_apigatewayv2, false)
  #   enable_ack_dynamodb                          = try(var.addons.enable_ack_dynamodb, false)
  #   enable_ack_s3                                = try(var.addons.enable_ack_s3, false)
  #   enable_ack_rds                               = try(var.addons.enable_ack_rds, false)
  #   enable_ack_prometheusservice                 = try(var.addons.enable_ack_prometheusservice, false)
  #   enable_ack_emrcontainers                     = try(var.addons.enable_ack_emrcontainers, false)
  #   enable_ack_sfn                               = try(var.addons.enable_ack_sfn, false)
  #   enable_ack_eventbridge                       = try(var.addons.enable_ack_eventbridge, false)
  # }
  # oss_addons = {
  #   enable_argocd                          = try(var.addons.enable_argocd, true)
  #   enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
  #   enable_argo_events                     = try(var.addons.enable_argo_events, false)
  #   enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
  #   enable_cluster_proportional_autoscaler = try(var.addons.enable_cluster_proportional_autoscaler, false)
  #   enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
  #   enable_gpu_operator                    = try(var.addons.enable_gpu_operator, false)
  #   enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
  #   enable_kyverno                         = try(var.addons.enable_kyverno, false)
  #   enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
  #   enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
  #   enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
  #   enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
  #   enable_vpa                             = try(var.addons.enable_vpa, false)
  # }