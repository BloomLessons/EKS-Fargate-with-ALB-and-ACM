############################
## Common
############################
variable "name" {
  type        = string
  description = "Project name"
}
variable "tags" {
  type        = map(string)
  description = "Resource tags"
}
variable "unique_id" {
  type        = string
  description = "Module resources unique identifier"
}
variable "vpc_id" {
  type        = string
  description = "VPC Identifier"
}

############################
## IAM
############################
variable "iam_role_path" {
  type        = string
  description = "Cluster IAM role path"
  default     = "/"
}

############################
## KMS
############################
variable "kms_key_deletion_window_in_days" {
  type        = number
  description = "Indicates the deletion period for the KMS key"
  default     = 30
}

############################
## EKS
############################
variable "enable_cluster_encryption" {
  type        = bool
  description = "Enable cluster encryption"
  default     = false
}
variable "cluster_version" {
  type        = string
  description = "EKS cluster version - kubernetes version"
  default     = "1.29"
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of the clusters subnet ids"
}
variable "security_group_ids" {
  type        = list(string)
  description = "Cluster security groups ids"
}
variable "cluster_timeouts" {
  type        = map(string)
  description = "Create, update and delete timeout for cluster"
  default = {
    create = null
    update = null
    delete = null
  }
}

#############################
## EKS Addons
#############################
variable "cluster_addons" {
  type        = any
  description = "Cluster addons to be installed"
  /* default = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  } */
}
variable "dataplane_wait_duration" {
  type        = string
  description = "The durtion to wait after which the EKS cluster has become active before creatting dataplane components (Fargate profile, Manged Nodes, Self Managed nodes)"
  default     = "40s"
}

variable "cluster_addons_timeouts" {
  type        = map(string)
  description = "EKS Cluster addons timeouts"
  default = {
    create = null
    update = null
    delete = null
  }
}
variable "cluster_encryption_config" {
  type        = any
  description = "Encryption configuration for the cluster"
  default = {
    resources = ["secrets"]
  }
}

############################
## Cloudwatch log group
############################
variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Create cloudwatch log group?"
  default     = false
}
variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of enabled cluster log types"
  default     = []
}
variable "cloudwatch_log_group_retention_days" {
  type        = number
  description = "Days to retains the log group logs"
  default     = 90
}
variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "The KMS key used to encrypt cloudwatch log group logs"
  default     = null
}

############################
## Fargate profiles
############################
variable "fargate_profiles" {
  type        = any
  description = "Specification for the fargate profile"
  /* default = {
    apps = {
      name = "apps"
      selectors = [
        {
          namespace = "app"
          labels = {
            name = "app"
          }
        },
        {
          namespace = "app-*"
          labels = {
            name = "app-*"
          }
        }
      ]
      subnet_ids = []
      unique_id  = "apps"
      timeouts = {
        create = "20m"
        delete = "20m"
      }
      create_iam_role               = true
      iam_role_attach_cni_policy    = false
      iam_role_additional_policies  = null
      pod_execution_assume_role_arn = null
      tags                          = {}
    }
  } */
}
