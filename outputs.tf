output "eks_cluster_name" {
  value = module.eks_fargate.name
}
## Get OIDC provider
output "eks_identity" {
  value = {
    full    = module.eks_fargate.identity
    oidc_id = local.oidc_id
  }
}

# lb role arn
output "eks_lb_controller_role" {
  value = {
    name = "${aws_iam_role.lb_controller_role.name}"
    arn  = "${aws_iam_role.lb_controller_role.arn}"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "aws_region" {
  value = var.aws_region
}
