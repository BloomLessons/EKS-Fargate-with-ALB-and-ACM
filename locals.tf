########################################
## Common local vars
########################################
locals {
  tags = {
    Project   = var.name
    Terraform = true
  }

  shared_egress_rule = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Egress"
      from_port        = "0"
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      to_port          = "0"
      self             = null
    }
  ]
}

########################################
## EKS Fargate security group rules
########################################
locals {
  eks_fargate_ingress_rules = [
    {
      cidr_blocks      = null
      description      = "Ingress EKS"
      from_port        = "0"
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      to_port          = "0"
      self             = true
    }
  ]
}

########################################
## EKS Fargate profiles
########################################
locals {
  eks_fargate_profiles = {
    kube-system = {
      name = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
          labels    = {}
        }
      ]
      subnet_ids = module.vpc.private_subnets
      unique_id  = "kube-system"
      timeouts = {
        create = "20m"
        delete = "20m"
      }
      create_iam_role               = true
      iam_role_attach_cni_policy    = false
      iam_role_additional_policies  = {}
      pod_execution_assume_role_arn = null
      tags                          = local.tags
    }

    coredns = {
      name = "CoreDNS"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            "k8s-app" = "kube-dns"
          }
        }
      ]
      subnet_ids = module.vpc.private_subnets
      unique_id  = "coredns"
      timeouts = {
        create = "20m"
        delete = "20m"
      }
      create_iam_role               = true
      iam_role_attach_cni_policy    = false
      iam_role_additional_policies  = {}
      pod_execution_assume_role_arn = null
      tags                          = local.tags
    }

    apps = {
      name = "apps"
      selectors = [
        {
          namespace = "default"
          labels = {
            "profile" = "apps"
          }
        },
        {
          namespace = "default"
          labels = {
            "profile" = "apps-*"
          }
        },
        {
          namespace = "apps"
          labels = {
            "profile" = "apps"
          }
        },
        {
          namespace = "apps-*"
          labels = {
            "profile" = "apps-*"
          }
        }
      ]
      subnet_ids = module.vpc.private_subnets
      unique_id  = "apps"
      timeouts = {
        create = "20m"
        delete = "20m"
      }
      create_iam_role               = true
      iam_role_attach_cni_policy    = false
      iam_role_additional_policies  = {}
      pod_execution_assume_role_arn = null
      tags                          = local.tags
    }
  }
}

########################################
## EKS cluster addons
########################################
locals {
  eks_cluster_addons = {
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }
}



##################################
## EKS get OIDC provider
##################################
locals {
  oidc_issuer = split("/", module.eks_fargate.identity[0].oidc[0].issuer)
  length      = length(local.oidc_issuer)
  oidc_id     = local.oidc_issuer[local.length - 1]
}
