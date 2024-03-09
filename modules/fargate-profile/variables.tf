##############################
## Common
##############################
variable "name" {
  type        = string
  description = "Project name"
}
variable "unique_id" {
  type        = string
  description = "Modules unique id for its resource names"
}
variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

##############################
## IAM
##############################
variable "create_iam_role" {
  type        = bool
  description = "Indicate whether to create profile iam role"
  default     = true
}
variable "pod_execution_assume_role_arn" {
  type        = string
  description = "Fargate pod execution assume role"
  default     = null
}
variable "iam_role_attach_cni_policy" {
  type        = bool
  description = "Whether to attache the cni policy"
  default     = false
}
variable "iam_role_additional_policies" {
  type        = map(string)
  description = "Additional policies for the fargate iam role"
  default     = {}
}

##############################
## Fargate profile
##############################

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}
variable "profile_name" {
  type        = string
  description = "Fargate profile name"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for this fargate profile"
}
variable "selectors" {
  type = list(object({
    namespace = string
    labels    = map(string)
  }))
  description = "Fargate profile selectors and namespaces"
  default = [
    {
      namespace = "app"
      labels = {
        "name" = "app"
      }
    },
    {
      namespace = "app-*"
      labels = {
        "name" = "app-*"
      }
    }
  ]
}
variable "timeouts" {
  type        = map(string)
  description = "Terraform lifecycle timeouts for fargate profile resources"
  default = {
    create = null
    delete = null
  }
}
