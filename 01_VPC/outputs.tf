# outputs.tf in 01_VPC folder
output "vpc_id" {
  value = local.vpc_id
}

output "vpc_cidr" {
  value = local.vpc_cidr
}

output "azs" {
  value = local.azs
}

output "public_subnets_cidrs" {
  value = local.public_subnets_cidrs
}

output "private_subnets_cidrs" {
  value = local.private_subnets_cidrs
}
