variable "name" {
  type        = string
  description = "Project name"
}
variable "vpc_id" {
  type        = string
  description = "Current VPC ID where the security group is created"
}
variable "unique_id" {
  type        = string
  description = "Unique identifier for the module"
}
variable "ingress_rules" {
  type = list(object({
    cidr_blocks      = list(string)
    description      = string
    from_port        = number
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    protocol         = string
    security_groups  = list(string)
    to_port          = number
    self             = bool
  }))
  description = "Ingress rules for the security group"
}

variable "egress_rules" {
  type = list(object({
    cidr_blocks      = list(string)
    description      = string
    from_port        = number
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    protocol         = string
    security_groups  = list(string)
    to_port          = number
    self             = bool
  }))
  description = "Egress rules for the security group"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags used in this modules"
  default     = {}
}
