

# module "admin_team" {
#   source = "aws-ia/eks-blueprints-teams/aws"

#   name = "admin-team"

#   # Enables elevated, admin privileges for this team
#   enable_admin = true
#   users        = [
#     "arn:aws:iam::977099011692:role/Admin", 
#     "arn:aws:iam::977099011692:user/eks_user"
#   ]
#   cluster_arn       = module.eks_al2023.cluster_arn
#   oidc_provider_arn = module.eks_al2023.oidc_provider_arn

#   tags = {
#     Environment = "dev"
#   }
# }


# ########## MEMO
# # eks_aws_auth 모듈과 충돌하고 있음