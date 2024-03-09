#######################################
## VPC 
#######################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  azs                  = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  cidr                 = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  public_subnets       = var.vpc_public_subnets
  public_subnet_tags   = var.vpc_public_subnets_tags
  private_subnets      = var.vpc_private_subnets
  private_subnet_tags  = var.vpc_private_subnets_tags

  tags = merge(
    local.tags,
    {
      Name = "${var.name}-vpc"
    }
  )
}

#######################################
## EKS Fargate cluster 
#######################################
module "eks_fargate_sg" {
  source = "./modules/security-group"

  name          = var.name
  vpc_id        = module.vpc.vpc_id
  unique_id     = var.eks_unique_id
  egress_rules  = local.shared_egress_rule
  ingress_rules = local.eks_fargate_ingress_rules

  depends_on = [module.vpc]
}

module "eks_fargate" {
  source = "./modules/fargate-cluster"

  name                            = var.name
  unique_id                       = var.eks_unique_id
  vpc_id                          = module.vpc.vpc_id
  iam_role_path                   = var.eks_default_iam_path
  kms_key_deletion_window_in_days = var.eks_kms_key_deletion_window_in_days
  enable_cluster_encryption       = var.eks_enable_cluster_encryption
  cluster_version                 = var.eks_cluster_version
  subnet_ids                      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  security_group_ids              = [module.eks_fargate_sg.id]
  cluster_timeouts                = var.eks_cluster_timeouts
  cluster_addons                  = local.eks_cluster_addons
  dataplane_wait_duration         = var.eks_dataplane_wait_duration
  cluster_addons_timeouts         = var.eks_cluster_addons_timeouts
  create_cloudwatch_log_group     = var.eks_create_cloudwatch_log_group
  cloudwatch_log_group_kms_key_id = var.eks_cloudwatch_log_group_kms_key_id
  fargate_profiles                = local.eks_fargate_profiles
  tags                            = local.tags

  depends_on = [module.eks_fargate_sg]
}

###########################################
## Configure cluster access locally
###########################################
resource "terraform_data" "configure_eks_kubectl" {
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_fargate.name}"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [module.eks_fargate]
}


###########################################
## AWS LoadBalancer controller
###########################################
resource "aws_iam_policy" "lb_controller_iam_policy" {
  name        = "${var.name}-lb-controller-policy"
  path        = "/"
  description = "LB controller policy for ${module.eks_fargate.name} fargate cluster"
  policy      = data.aws_iam_policy_document.lb_controller.json
}
resource "aws_iam_role" "lb_controller_role" {
  name               = "${var.name}-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_role_trust_policy.json
}
resource "aws_iam_role_policy_attachment" "lb_role_policy_attachement" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_iam_policy.arn
}
