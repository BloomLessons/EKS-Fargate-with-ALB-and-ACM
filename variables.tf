################################
## Commong variables
################################
variable "aws_region" {
  type        = string
  description = "AWS region for current resources"
  default     = "us-west-2" #TAKE NOTE OF THIS, IF YOU CHANGE IT UPDATE THE OTHER RESOURCES ACCORDINGLY
}
variable "name" {
  type        = string
  description = "Project name"
  default     = "bloomlessons"
}

################################
## VPC variables
################################
variable "vpc_cidr" {
  type        = string
  description = "VPC CI/DR block"
  default     = "172.16.0.0/16"
}
variable "vpc_private_subnets" {
  type        = list(string)
  description = "Private subnets"
  default     = ["172.16.0.0/18", "172.16.64.0/18"]
}
variable "vpc_public_subnets" {
  type        = list(string)
  description = "Public subnets"
  default     = ["172.16.128.0/18", "172.16.192.0/18"]
}
variable "vpc_private_subnets_tags" {
  type        = map(string)
  description = "Tags to attach on the private subnets"
  default = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
variable "vpc_public_subnets_tags" {
  type        = map(string)
  description = "Tags to attach on the public subnets"
  default = {
    "kubernetes.io/role/elb" : "1"
  }
}

################################
## EKS variables
################################
variable "eks_unique_id" {
  type        = string
  description = "Unique id for the eks module resourses"
  default     = "fargate" # dev, staging, pilot
}
variable "eks_default_iam_path" {
  type        = string
  description = "IAM role path for EKS role"
  default     = "/"
}
variable "eks_kms_key_deletion_window_in_days" {
  type        = number
  description = "KMS deletion days after which the key will be deleted"
  default     = 30
}
variable "eks_enable_cluster_encryption" {
  type        = bool
  description = "Whether to enable EKS encryption"
  default     = false
}
variable "eks_cluster_version" {
  type        = string
  description = "Indicate the cluster version"
  default     = "1.29"
}
variable "eks_cluster_timeouts" {
  type        = map(string)
  description = "Terraform lifecycle timeouts"
  default = {
    create = null
    delete = null
    update = null
  }
}
variable "eks_dataplane_wait_duration" {
  type        = string
  description = "Duration to wait after cluster creation before creating the dataplne components"
  default     = "40s"
}
variable "eks_cluster_addons_timeouts" {
  type        = map(string)
  description = "Terraform lifecycle timeouts"
  default = {
    create = null
    delete = null
    update = null
  }
}
variable "eks_enabled_cluster_log_types" {
  type        = list(string)
  description = "Enabled log types on the EKS cluster"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
variable "eks_create_cloudwatch_log_group" {
  type        = bool
  description = "Indicate whether to create the EKS cloudwatch logroup"
  default     = true
}
variable "eks_cloudwatch_log_group_retention_days" {
  type        = number
  description = "Number days to retain the log group on CloudWatch"
  default     = 90
}
variable "eks_cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "KMS key ID to be used to encrypt cloudwatch group logs for EKS"
  default     = null
}
