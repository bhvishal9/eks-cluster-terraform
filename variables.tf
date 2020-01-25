variable "aws_profile" {
  description = "Name of the AWS profile, required by terraform to access AWS"
  default     = "temp-admin"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  default     = "eks-demo"
}

variable "cluster_version" {
  description = "Kubernetes cluster version supported by EKS"
  default     = "1.14"
}

variable "node_count" {
  description = "Number of nodes in the EKS cluster node group"
  default     = 2
}

variable "node_instance_size" {
  description = "Instance size of EKS nodes"
  default     = "t3.medium"
}

variable "region" {
  description = "The AWS region in which the resources will be created"
  default     = "eu-west-1"
}

variable "subnet_count" {
  description = "Number of subnets"
  default     = "3"
}

variable "vpc_cidr" {
  description = "CIDR range for the cluster VPC"
  default     = "172.20.0.0/16"
}

variable "vpc_cidr_extension_bits" {
  default = "6"
}

variable "vpc_cidr_extension_start" {
  default = "48"
}
