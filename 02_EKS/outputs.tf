output "cluster_name" {
  value = module.eks_al2023.cluster_name
}

output "cluster_version" {
  value = module.eks_al2023.cluster_version
}

output "cluster_id" {
  value = module.eks_al2023.cluster_id
}

output "cluster_endpoint" {
  value = module.eks_al2023.cluster_endpoint
}

output "oidc_provider" {
  value = module.eks_al2023.oidc_provider
}

output "oidc_provider_arn" {
  value = module.eks_al2023.oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  value = module.eks_al2023.cluster_certificate_authority_data
}


output "access_argocd" {
  description = "ArgoCD Access"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${local.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${local.cluster_name}
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    echo "ArgoCD URL: https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    EOT
}


