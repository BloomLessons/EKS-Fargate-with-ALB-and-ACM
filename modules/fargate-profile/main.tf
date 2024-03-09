#####################################
## IAM Role
#####################################
resource "aws_iam_role" "main" {
  count = var.create_iam_role ? 1 : 0

  name                  = "${var.name}-${var.unique_id}-assume-role"
  description           = "Fargate profile assume role for ${var.name}-${var.unique_id}-assume-role"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  force_detach_policies = true

  tags = merge({ Name = "${var.name}-${var.unique_id}-assume-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "main" {
  for_each = {
    for k, v in toset(compact([
      "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
      var.iam_role_attach_cni_policy ? local.cni_policy_arn : null
    ])) : k => v if var.create_iam_role && v != null
  }
  policy_arn = each.value
  role       = aws_iam_role.main[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = {
    for k, v in var.iam_role_additional_policies : k => v if var.create_iam_role == true
  }
  policy_arn = each.value
  role       = aws_iam_role.main[0].name
}

#################################
# Fargate Profile
#################################
resource "aws_eks_fargate_profile" "main" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.profile_name
  pod_execution_role_arn = var.create_iam_role ? aws_iam_role.main[0].arn : var.pod_execution_assume_role_arn
  subnet_ids             = var.subnet_ids
  dynamic "selector" {
    for_each = toset(var.selectors)
    content {
      namespace = selector.value.namespace
      labels    = lookup(selector.value, "labels", {})
    }
  }
  dynamic "timeouts" {
    for_each = [var.timeouts]
    content {
      #   create = timeouts.value.create
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }
  tags = var.tags
}
