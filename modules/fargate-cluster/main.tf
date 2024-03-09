############################
## KMS Key
############################
module "kms_key" {
  source                  = "terraform-aws-modules/kms/aws"
  version                 = "2.1.0"
  create                  = var.enable_cluster_encryption
  description             = "EKS encryption key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  tags                    = var.tags
}

############################
## IAM role
############################
resource "aws_iam_role" "assume_role" {
  name                  = "${var.name}-${var.unique_id}-assume-role"
  path                  = var.iam_role_path
  description           = "IAM assume role for EKS"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "managed_polices" {
  for_each = {
    for k, v in {
      AmazonEKSClusterPolicy         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    } : k => v if v != null
  }
  policy_arn = each.value
  role       = aws_iam_role.assume_role.name
}

resource "aws_iam_policy" "cluster_encryption" {
  count       = var.enable_cluster_encryption ? 1 : 0
  name        = "${var.name}-${var.unique_id}-enc-policy"
  description = "EKS Cluster encryption policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = module.kms_key.key_arn
      },
    ]
  })
  tags = merge(var.tags, { Name = "${var.name}-${var.unique_id}-enc-policy" })
}
resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  count      = var.enable_cluster_encryption ? 1 : 0
  policy_arn = aws_iam_policy.cluster_encryption[0].arn
  role       = aws_iam_role.assume_role.name
}

############################
## EKS cluster
############################
resource "aws_eks_cluster" "main" {
  name                      = local.cluster_name
  role_arn                  = aws_iam_role.assume_role.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    security_group_ids     = var.security_group_ids
    subnet_ids             = var.subnet_ids
    endpoint_public_access = true
  }

  tags = merge(var.tags, { Name = local.cluster_name })

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }
  depends_on = [
    aws_iam_role_policy_attachment.managed_polices,
    aws_cloudwatch_log_group.main
  ]
}

resource "time_sleep" "main" {
  create_duration = var.dataplane_wait_duration

  triggers = {
    cluster_name                  = aws_eks_cluster.main.name
    cluster_endpoint              = aws_eks_cluster.main.endpoint
    cluster_version               = aws_eks_cluster.main.version
    cluster_certificate_authority = aws_eks_cluster.main.certificate_authority[0].data
  }
}


############################
## Cloudwatch log group
############################
resource "aws_cloudwatch_log_group" "main" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cloudwatch_log_group_retention_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = merge(var.tags, { Name = "/aws/eks/${local.cluster_name}/cluster" })
}


###############################
## EKS Addons
###############################
resource "aws_eks_addon" "main" {
  for_each = { for k, v in var.cluster_addons : k => v if v != null }

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = try(each.value.name, each.key)
  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.main[each.key].version)
  configuration_values        = try(each.value.configuration_values, null)
  preserve                    = try(each.value.preserve, null)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  depends_on = [
    module.fargate_profile
  ]
  tags = var.tags
}

###############################
## Fargate Profile
###############################
module "fargate_profile" {
  source   = "../fargate-profile"
  for_each = { for k, v in var.fargate_profiles : k => v if v != null }

  cluster_name                  = aws_eks_cluster.main.name
  name                          = var.name
  profile_name                  = try(each.value.name, each.key)
  selectors                     = each.value.selectors
  subnet_ids                    = each.value.subnet_ids
  unique_id                     = each.value.unique_id
  create_iam_role               = each.value.create_iam_role
  iam_role_attach_cni_policy    = each.value.iam_role_attach_cni_policy
  iam_role_additional_policies  = each.value.iam_role_additional_policies
  pod_execution_assume_role_arn = each.value.pod_execution_assume_role_arn

  tags = merge(each.value.tags, { Name = try(each.value.name, each.key) })
}
