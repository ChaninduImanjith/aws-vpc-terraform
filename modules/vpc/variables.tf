variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "Base CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "enable_single_nat_gateway" {
  description = "If true, provisions a single NAT gateway to reduce cost in non-prod"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags for resources"
  type        = map(string)
  default     = {}
}
