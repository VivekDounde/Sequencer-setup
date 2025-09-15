variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "arbitrum-prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_azs" {
  type    = list(string)
  default = ["us-east-1a","us-east-1b","us-east-1c"]
}

variable "ondemand_node_count" { type = number; default = 3 }
variable "spot_node_count"     { type = number; default = 2 }

# Replace these with your production sizing
variable "ondemand_instance_type" { type = string; default = "m6i.large" }
variable "spot_instance_types" { type = list(string); default = ["m6i.large","m5a.large","m6i.xlarge"] }

# For helm releases and charts
variable "chart_namespace" { type = string; default = "arbitrum" }
