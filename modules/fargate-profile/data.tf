data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_role ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}
