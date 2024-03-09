locals {
  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam:aws:policy"
  cni_policy_arn         = "${local.iam_role_policy_prefix}/Amazon_CNI_Policy"
}
