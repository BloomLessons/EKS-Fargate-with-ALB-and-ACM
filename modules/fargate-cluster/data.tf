data "aws_partition" "current" {}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}


data "aws_eks_addon_version" "main" {
  for_each = { for k, v in var.cluster_addons : k => v if v != null }

  addon_name         = try(each.value.name, each.key)
  kubernetes_version = coalesce(var.cluster_version, aws_eks_cluster.main.version)
  most_recent        = try(each.value.most_recent, null)
}
