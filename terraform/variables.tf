variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_name" {
  type        = string
  description = "Name of VPC"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS Cluster"
}

variable "node_group_name" {
  type        = string
  description = "Name of the EKS Node Group"
}

variable "ng_instance_types" {
  type        = list(string)
  description = "List of instance types associated with the EKS Node Group"
}

variable "disk_size" {
  description = "Disk Size for Worker Nodes in GiB"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
}

variable "fargate_profile_name" {
  type        = string
  description = "Name of the Fargate Profile"
}

variable "fargate_namespaces" {
  type        = list(string)
  description = "Kubernetes namespaces for fargate profiles"
}

variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "availability_zones" {
  type        = list(string)
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "private_subnets" {
  type        = list(string)
  description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
}

variable "public_subnets" {
  type        = list(string)
  description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
}

variable "eks_cluster_version" {
  type        = string
  description = "The EKS cluster version"
}
